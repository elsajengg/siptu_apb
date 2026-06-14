<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
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
}
