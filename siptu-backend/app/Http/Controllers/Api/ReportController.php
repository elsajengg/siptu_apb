<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Facility;
use App\Models\Report;
use App\Models\User;
use App\Services\UserNotifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ReportController extends Controller
{
    private function withLikeFlag(Request $request, $query)
    {
        $userId = $request->user()->id;
        return $query->withExists(['likedByUsers as is_liked_by_me' => fn ($q) => $q->where('user_id', $userId)]);
    }

    public function feed(Request $request): JsonResponse
    {
        $query = Report::query()
            ->with([
                'user:id,name',
                'facility.room',
                'photos',
                'task.staff:id,name,nip',
                'task.updates.author:id,name',
                'task.updates.photos',
            ])
            ->latest()
            ->limit(min($request->integer('per_page', 30), 50));

        $query = $this->withLikeFlag($request, $query);

        $reports = $query->paginate(min($request->integer('per_page', 30), 50));

        return response()->json($reports);
    }

    public function index(Request $request): JsonResponse
    {
        $query = Report::query()->with([
            'user:id,name',
            'facility.room',
            'photos',
            'task.staff:id,name,nip',
            'task.updates.author:id,name',
            'task.updates.photos',
        ]);

        if ($request->user()->role === 'user') {
            $query->where('user_id', $request->user()->id);
        } elseif ($request->user()->role === 'staff') {
            $query->whereHas('task', fn ($task) => $task->where('staff_id', $request->user()->id));
        }

        $query
            ->when($request->filled('status'), fn ($builder) => $builder->where('status', $request->string('status')))
            ->when($request->filled('category'), fn ($builder) => $builder->where('category', $request->string('category')))
            ->latest();

        $query = $this->withLikeFlag($request, $query);

        return response()->json($query->paginate(min($request->integer('per_page', 15), 50)));
    }

    public function store(Request $request, UserNotifier $notifier): JsonResponse
    {
        $data = $request->validate([
            'facility_id' => ['required', 'exists:facilities,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:5000'],
            'location' => ['required', 'string', 'max:255'],
            'room_detail' => ['nullable', 'string', 'max:255'],
            'photos' => ['nullable', 'array', 'max:5'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $report = DB::transaction(function () use ($request, $data) {
            $facility = Facility::findOrFail($data['facility_id']);
            $report = Report::create([
                ...collect($data)->except('photos')->all(),
                'ticket_number' => $this->ticketNumber(),
                'user_id' => $request->user()->id,
                'category' => $facility->category,
                'status' => 'pending',
            ]);

            foreach ($request->file('photos', []) as $photo) {
                $stored = $report->photos()->create([
                    'path' => $photo->store("reports/{$report->id}", 'public'),
                    'original_name' => $photo->getClientOriginalName(),
                ]);

                if (! $report->photo_path) {
                    $report->update(['photo_path' => $stored->path]);
                }
            }

            return $report;
        });

        $notifier->send(
            User::where('role', 'admin')->get(),
            'report.created',
            'Laporan baru',
            "{$request->user()->name} mengirim {$report->ticket_number}.",
            ['report_id' => $report->id, 'ticket_number' => $report->ticket_number],
        );

        return response()->json([
            'message' => 'Laporan berhasil dibuat.',
            'data' => $report->load(['facility.room', 'photos']),
        ], 201);
    }

    public function show(Request $request, Report $report): JsonResponse
    {
        $canView = $request->user()->role === 'admin'
            || $report->user_id === $request->user()->id
            || $report->task?->staff_id === $request->user()->id;

        abort_unless($canView, 403);

        $report->load([
            'user:id,name',
            'facility.room',
            'photos',
            'task.staff:id,name,nip',
            'task.updates.author:id,name',
            'task.updates.photos',
        ]);

        $report->is_liked_by_me = $report->likedByUsers()->where('user_id', $request->user()->id)->exists();

        return response()->json(['data' => $report]);
    }

    public function like(Request $request, Report $report, UserNotifier $notifier): JsonResponse
    {
        $userId = $request->user()->id;
        $existing = DB::table('report_likes')
            ->where('report_id', $report->id)
            ->where('user_id', $userId)
            ->first();

        if ($existing) {
            DB::table('report_likes')
                ->where('report_id', $report->id)
                ->where('user_id', $userId)
                ->delete();
            $report->decrement('likes_count');
            $liked = false;
        } else {
            DB::table('report_likes')->insert([
                'report_id' => $report->id,
                'user_id' => $userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $report->increment('likes_count');
            $liked = true;
        }

        $report->refresh();

        if ($liked && $report->user_id !== $userId) {
            $notifier->send(
                $report->user,
                'report.liked',
                'Dukungan baru',
                "{$request->user()->name} memberi dukungan pada {$report->ticket_number}.",
                [
                    'report_id' => $report->id,
                    'ticket_number' => $report->ticket_number,
                    'likes_count' => $report->likes_count,
                ],
            );
        }

        return response()->json([
            'liked' => $liked,
            'likes_count' => $report->likes_count,
        ]);
    }

    public function reject(Request $request, Report $report, UserNotifier $notifier): JsonResponse
    {
        $data = $request->validate(['reason' => ['required', 'string', 'max:2000']]);

        abort_if($report->task()->exists(), 422, 'Laporan yang sudah ditugaskan tidak dapat ditolak.');

        $report->update([
            'status' => 'rejected',
            'rejection_reason' => $data['reason'],
        ]);

        $notifier->send(
            $report->user,
            'report.rejected',
            'Laporan ditolak',
            "{$report->ticket_number} ditolak: {$data['reason']}",
            ['report_id' => $report->id, 'ticket_number' => $report->ticket_number],
        );

        return response()->json(['message' => 'Laporan ditolak.', 'data' => $report]);
    }

    public function feedback(Request $request, Report $report): JsonResponse
    {
        abort_unless($report->user_id === $request->user()->id, 403);
        abort_unless($report->status === 'resolved', 422, 'Feedback hanya dapat diberikan setelah laporan selesai.');

        $data = $request->validate([
            'rating' => ['required', 'integer', 'between:1,5'],
            'feedback_notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $report->update($data);

        return response()->json(['message' => 'Feedback berhasil disimpan.', 'data' => $report]);
    }

    private function ticketNumber(): string
    {
        return 'TIK-'.now()->format('Ymd-His').'-'.strtoupper(Str::random(4));
    }
}
