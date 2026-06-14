<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\Task;
use App\Models\User;
use App\Services\UserNotifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AssignmentController extends Controller
{
    public function store(Request $request, Report $report, UserNotifier $notifier): JsonResponse
    {
        $data = $request->validate([
            'staff_id' => [
                'required',
                Rule::exists('users', 'id')->where(fn ($query) => $query->where('role', 'staff')),
            ],
            'admin_notes' => ['nullable', 'string', 'max:3000'],
            'deadline_at' => ['nullable', 'date', 'after:now'],
        ]);

        abort_if($report->status === 'rejected', 422, 'Laporan yang ditolak tidak dapat ditugaskan.');
        abort_if($report->task()->exists(), 422, 'Laporan ini sudah memiliki penugasan.');

        $task = DB::transaction(function () use ($request, $report, $data) {
            $task = Task::create([
                ...$data,
                'task_number' => 'TGS-'.now()->format('Ymd-His').'-'.strtoupper(Str::random(4)),
                'report_id' => $report->id,
                'assigned_by' => $request->user()->id,
                'status' => 'assigned',
            ]);

            $report->update([
                'status' => 'assigned',
                'rejection_reason' => null,
            ]);

            return $task;
        });

        $staff = User::findOrFail($data['staff_id']);

        $notifier->send(
            $staff,
            'task.assigned',
            'Penugasan baru',
            "Anda ditugaskan menangani {$report->ticket_number}: {$report->title}.",
            ['task_id' => $task->id, 'report_id' => $report->id],
        );

        $notifier->send(
            $report->user,
            'report.assigned',
            'Laporan sedang ditangani',
            "{$report->ticket_number} telah ditugaskan kepada {$staff->name}.",
            ['task_id' => $task->id, 'report_id' => $report->id],
        );

        return response()->json([
            'message' => 'Staff berhasil ditugaskan.',
            'data' => $task->load(['report', 'staff:id,name,nip', 'assignedBy:id,name']),
        ], 201);
    }
}
