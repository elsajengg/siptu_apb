<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Task extends Model
{
    protected $fillable = [
        'task_number',
        'report_id',
        'assigned_by',
        'staff_id',
        'admin_notes',
        'staff_notes',
        'status',
        'deadline_at',
        'started_at',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'deadline_at' => 'datetime',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
    }

    public function staff(): BelongsTo
    {
        return $this->belongsTo(User::class, 'staff_id');
    }

    public function assignedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_by');
    }

    public function updates(): HasMany
    {
        return $this->hasMany(TaskUpdate::class);
    }
}
