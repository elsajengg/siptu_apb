<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Facility extends Model
{
    protected $fillable = ['room_id', 'name', 'category', 'code', 'status'];

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }
}
