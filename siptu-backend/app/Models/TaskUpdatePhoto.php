<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TaskUpdatePhoto extends Model
{
    protected $fillable = ['task_update_id', 'path', 'original_name'];

    public function taskUpdate(): BelongsTo
    {
        return $this->belongsTo(TaskUpdate::class);
    }
}
