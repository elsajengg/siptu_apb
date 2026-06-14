<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nip', 50)->nullable()->unique()->after('role');
        });

        Schema::table('facilities', function (Blueprint $table) {
            $table->foreignId('room_id')->nullable()->after('id')->constrained()->nullOnDelete();
            $table->string('name')->nullable()->after('room_id');
            $table->string('category', 80)->nullable()->after('name')->index();
            $table->string('code', 50)->nullable()->unique()->after('category');
            $table->string('status', 30)->default('active')->index()->after('code');
        });

        Schema::table('reports', function (Blueprint $table) {
            $table->string('ticket_number', 40)->nullable()->unique()->after('id');
            $table->string('title')->nullable()->after('facility_id');
            $table->string('location')->nullable()->after('description');
            $table->string('category', 80)->nullable()->index()->after('location');
            $table->text('rejection_reason')->nullable()->after('status');
        });

        Schema::create('report_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('report_id')->constrained()->cascadeOnDelete();
            $table->string('path');
            $table->string('original_name')->nullable();
            $table->timestamps();
        });

        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->string('task_number', 40)->unique();
            $table->foreignId('report_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('assigned_by')->constrained('users')->restrictOnDelete();
            $table->foreignId('staff_id')->constrained('users')->restrictOnDelete();
            $table->text('admin_notes')->nullable();
            $table->text('staff_notes')->nullable();
            $table->enum('status', ['assigned', 'on_progress', 'blocked', 'resolved'])
                ->default('assigned')
                ->index();
            $table->timestamp('deadline_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('task_updates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('task_id')->constrained()->cascadeOnDelete();
            $table->foreignId('created_by')->constrained('users')->restrictOnDelete();
            $table->enum('status', ['on_progress', 'blocked', 'resolved'])->index();
            $table->text('notes');
            $table->timestamps();
        });

        Schema::create('task_update_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('task_update_id')->constrained()->cascadeOnDelete();
            $table->string('path');
            $table->string('original_name')->nullable();
            $table->timestamps();
        });

        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('token', 512);
            $table->string('platform', 20)->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'token']);
        });

        Schema::create('user_notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type', 80)->index();
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_notifications');
        Schema::dropIfExists('device_tokens');
        Schema::dropIfExists('task_update_photos');
        Schema::dropIfExists('task_updates');
        Schema::dropIfExists('tasks');
        Schema::dropIfExists('report_photos');

        Schema::table('reports', function (Blueprint $table) {
            $table->dropColumn(['ticket_number', 'title', 'location', 'category', 'rejection_reason']);
        });

        Schema::table('facilities', function (Blueprint $table) {
            $table->dropConstrainedForeignId('room_id');
            $table->dropColumn(['name', 'category', 'code', 'status']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('nip');
        });
    }
};
