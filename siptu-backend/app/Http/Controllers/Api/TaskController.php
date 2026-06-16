<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\User;
use App\Services\UserNotifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class TaskController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Task::query()->with(['report.photos', 'staff:id,name,nip', 'updates.photos']);

        if ($request->user()->role === 'staff') {
            $query->where('staff_id', $request->user()->id);
        }

        $query
            ->when($request->filled('status'), fn ($builder) => $builder->where('status', $request->string('status')))
            ->latest();

        return response()->json($query->paginate(min($request->integer('per_page', 15), 50)));
    }

    public function show(Request $request, Task $task): JsonResponse
    {
        abort_unless(
            $request->user()->role === 'admin' || $task->staff_id === $request->user()->id,
            403,
        );

        return response()->json([
            'data' => $task->load([
                'report.user:id,name',
                'report.photos',
                'staff:id,name,nip',
                'assignedBy:id,name',
                'updates.author:id,name',
                'updates.photos',
            ]),
        ]);
    }

    public function addUpdate(Request $request, Task $task, UserNotifier $notifier): JsonResponse
    {
        abort_unless($task->staff_id === $request->user()->id, 403);

        if ($task->status === 'resolved' || $task->report->status === 'resolved') {
            return response()->json([
                'message' => 'Tugas sudah selesai dan tidak dapat diperbarui lagi.',
            ], 422);
        }

        $data = $request->validate([
            'status' => ['required', Rule::in(['on_progress', 'blocked', 'resolved'])],
            'notes' => ['required', 'string', 'max:5000'],
            'photos' => ['nullable', 'array', 'max:5'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        if ($data['status'] === 'resolved' && count($request->file('photos', [])) === 0) {
            return response()->json([
                'message' => 'Minimal satu foto bukti wajib untuk status resolved.',
            ], 422);
        }

        $update = DB::transaction(function () use ($request, $task, $data) {
            $update = $task->updates()->create([
                'created_by' => $request->user()->id,
                'status' => $data['status'],
                'notes' => $data['notes'],
            ]);

            foreach ($request->file('photos', []) as $photo) {
                $update->photos()->create([
                    'path' => $photo->store("tasks/{$task->id}/updates/{$update->id}", 'public'),
                    'original_name' => $photo->getClientOriginalName(),
                ]);
            }

            $taskChanges = [
                'status' => $data['status'],
                'staff_notes' => $data['notes'],
            ];

            if ($data['status'] === 'on_progress' && ! $task->started_at) {
                $taskChanges['started_at'] = now();
            }

            if ($data['status'] === 'resolved') {
                $taskChanges['completed_at'] = now();
            }

            $task->update($taskChanges);
            $task->report->update([
                'status' => $data['status'] === 'resolved' ? 'resolved' : 'on_progress',
            ]);

            return $update;
        });

        $statusLabel = match ($data['status']) {
            'on_progress' => 'sedang diproses',
            'blocked' => 'terkendala',
            'resolved' => 'selesai',
        };

        $recipients = User::where('role', 'admin')->get()->push($task->report->user);

        $notifier->send(
            $recipients,
            'task.updated',
            'Update pekerjaan',
            "{$task->task_number} kini {$statusLabel}.",
            [
                'task_id' => $task->id,
                'report_id' => $task->report_id,
                'status' => $data['status'],
            ],
        );

        return response()->json([
            'message' => 'Update tugas berhasil diunggah.',
            'data' => $update->load('photos'),
        ], 201);
    }
}
