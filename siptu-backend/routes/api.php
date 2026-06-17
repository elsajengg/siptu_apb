<?php

use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\FacilityController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', function (Request $request) {
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required', 'string'],
    ]);

    if (!auth()->attempt($credentials)) {
        return response()->json(['message' => 'Email atau password salah'], 401);
    }

    $user = auth()->user();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'message' => 'Login berhasil',
        'token' => $token,
        'user' => $user,
    ]);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [UserController::class, 'me']);
    Route::patch('/user', [UserController::class, 'updateMe']);
    Route::patch('/user/password', [UserController::class, 'updatePassword']);
    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout berhasil.']);
    });

    // Rooms & Facilities
    Route::get('/rooms', [RoomController::class, 'index']);
    Route::get('/facilities', [FacilityController::class, 'index']);

    // Staff (admin only)
    Route::get('/staff', [UserController::class, 'staff'])->middleware('role:admin');
    Route::post('/staff', [UserController::class, 'storeStaff'])->middleware('role:admin');
    Route::patch('/staff/{staff}', [UserController::class, 'updateStaff'])->middleware('role:admin');
    Route::delete('/staff/{staff}', [UserController::class, 'destroyStaff'])->middleware('role:admin');

    // Reports
    Route::get('/reports/feed', [ReportController::class, 'feed']);
    Route::get('/reports', [ReportController::class, 'index']);
    Route::post('/reports', [ReportController::class, 'store'])->middleware('role:user');
    Route::get('/reports/{report}', [ReportController::class, 'show']);
    Route::post('/reports/{report}/like', [ReportController::class, 'like']);
    Route::post('/reports/{report}/reject', [ReportController::class, 'reject'])->middleware('role:admin');
    Route::post('/reports/{report}/assign', [AssignmentController::class, 'store'])->middleware('role:admin');
    Route::post('/reports/{report}/feedback', [ReportController::class, 'feedback'])->middleware('role:user');

    // Tasks
    Route::get('/tasks', [TaskController::class, 'index'])->middleware('role:admin,staff');
    Route::get('/tasks/{task}', [TaskController::class, 'show'])->middleware('role:admin,staff');
    Route::post('/tasks/{task}/updates', [TaskController::class, 'addUpdate'])->middleware('role:staff');

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/test', [NotificationController::class, 'test']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'readAll']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'read']);
    Route::post('/devices', [NotificationController::class, 'registerDevice']);
    Route::delete('/devices', [NotificationController::class, 'unregisterDevice']);
});

Route::get('/image/{path}', function ($path) {
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath)) {
        return response()->json(['message' => 'Not found'], 404);
    }
    return response()->file($fullPath, [
        'Access-Control-Allow-Origin' => '*',
        'Content-Type' => mime_content_type($fullPath),
    ]);
})->where('path', '.*');

Route::get('/image/{path}', function ($path) {
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath)) {
        return response()->json(['message' => 'Not found'], 404);
    }
    return response()->file($fullPath, [
        'Access-Control-Allow-Origin' => '*',
        'Content-Type' => mime_content_type($fullPath),
    ]);
})->where('path', '.*');