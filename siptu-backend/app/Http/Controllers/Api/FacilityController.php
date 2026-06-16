<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Facility;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FacilityController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $facilities = Facility::query()
            ->with('room')
            ->where('status', 'active')
            ->when(
                $request->filled('room_id'),
                fn ($query) => $query->where('room_id', $request->integer('room_id'))
            )
            ->when(
                $request->filled('category'),
                fn ($query) => $query->where('category', $request->string('category'))
            )
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $facilities]);
    }
}
