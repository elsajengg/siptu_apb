<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function me(Request $request): JsonResponse
    {
        return response()->json(['data' => $request->user()]);
    }

    public function updateMe(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
        ]);

        $user->update($data);

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => $user->fresh(),
        ]);
    }

    public function updatePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $request->user()->update(['password' => $data['password']]);

        return response()->json(['message' => 'Kata sandi berhasil diperbarui.']);
    }

    public function staff(): JsonResponse
    {
        $staff = User::query()
            ->where('role', 'staff')
            ->withCount([
                'assignedTasks as active_tasks_count' => fn ($query) => $query->whereNot('status', 'resolved'),
            ])
            ->orderBy('name')
            ->get(['id', 'name', 'email', 'nip']);

        return response()->json(['data' => $staff]);
    }

    public function storeStaff(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'nip' => ['nullable', 'string', 'max:50', 'unique:users,nip'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        $staff = User::create([...$data, 'role' => 'staff']);

        return response()->json([
            'message' => 'Staff berhasil ditambahkan.',
            'data' => $staff,
        ], 201);
    }

    public function updateStaff(Request $request, User $staff): JsonResponse
    {
        abort_unless($staff->role === 'staff', 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users')->ignore($staff->id)],
            'nip' => ['nullable', 'string', 'max:50', Rule::unique('users')->ignore($staff->id)],
            'password' => ['nullable', 'string', 'min:8'],
        ]);

        if (blank($data['password'] ?? null)) {
            unset($data['password']);
        }
        $staff->update($data);

        return response()->json([
            'message' => 'Staff berhasil diperbarui.',
            'data' => $staff->fresh(),
        ]);
    }

    public function destroyStaff(User $staff): JsonResponse
    {
        abort_unless($staff->role === 'staff', 404);
        abort_if($staff->assignedTasks()->exists(), 422, 'Staff masih memiliki riwayat tugas dan tidak dapat dihapus.');

        $staff->delete();

        return response()->json(['message' => 'Staff berhasil dihapus.']);
    }
}
