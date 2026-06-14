<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Room extends Model
{
    protected $fillable = ['building_name', 'room_name'];

    public function facilities(): HasMany
    {
        return $this->hasMany(Facility::class);
    }
}
