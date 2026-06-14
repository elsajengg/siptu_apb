<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/login', function (Request $request) {
    $credentials = $request->only('email', 'password');

    if (!auth()->attempt($credentials)) {
        return response()->json(['message' => 'Email atau password salah'], 401);
    }

    $user = auth()->user();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'message' => 'Login berhasil',
        'token' => $token,
        'user' => $user
    ]);
});
