<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\JsonResponse;

class RoomController extends Controller
{
    public function index(): JsonResponse
    {
        $rooms = Room::with(['facilities' => fn ($q) => $q->where('status', 'active')->orderBy('name')])
            ->orderBy('building_name')
            ->orderBy('room_name')
            ->get();

        return response()->json(['data' => $rooms]);
    }
}
