<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserNotification;
use App\Services\UserNotifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            $request->user()
                ->userNotifications()
                ->latest()
                ->paginate(min($request->integer('per_page', 20), 50))
        );
    }

    public function read(Request $request, UserNotification $notification): JsonResponse
    {
        abort_unless($notification->user_id === $request->user()->id, 403);

        $notification->update(['read_at' => now()]);

        return response()->json([
            'message' => 'Notifikasi ditandai sudah dibaca.',
            'data' => $notification,
        ]);
    }

    public function readAll(Request $request): JsonResponse
    {
        $request->user()
            ->userNotifications()
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['message' => 'Semua notifikasi ditandai sudah dibaca.']);
    }

    public function registerDevice(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'platform' => ['nullable', 'in:android,ios,web,windows'],
        ]);

        $device = $request->user()->deviceTokens()->updateOrCreate(
            ['token' => $data['token']],
            [
                'platform' => $data['platform'] ?? null,
                'last_used_at' => now(),
            ],
        );

        return response()->json([
            'message' => 'Token Firebase tersimpan.',
            'data' => $device,
        ]);
    }

    public function unregisterDevice(Request $request): JsonResponse
    {
        $data = $request->validate(['token' => ['required', 'string']]);

        $request->user()->deviceTokens()->where('token', $data['token'])->delete();

        return response()->json(['message' => 'Token Firebase dihapus.']);
    }

    public function test(Request $request, UserNotifier $notifier): JsonResponse
    {
        abort_unless(app()->environment(['local', 'testing']), 404);

        $deviceCount = $request->user()->deviceTokens()->count();
        if ($deviceCount === 0) {
            return response()->json([
                'message' => 'Belum ada FCM token untuk akun ini. Login dari aplikasi Flutter terlebih dahulu.',
                'registered_devices' => 0,
            ], 422);
        }

        $push = $notifier->send(
            $request->user(),
            'notification.test',
            'Tes notifikasi SIPTU',
            'FCM sudah terhubung. Pesan ini dikirim dari backend Laravel.',
            ['screen' => 'notifications'],
        );

        return response()->json([
            'message' => $push['successful'] > 0
                ? 'Notifikasi uji berhasil dikirim.'
                : 'Firebase menerima permintaan, tetapi tidak ada push yang berhasil.',
            'registered_devices' => $deviceCount,
            'push' => $push,
        ]);
    }
}
