<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();  // Otomatis menjadi reports_id
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('facility_id')->constrained('facilities')->onDelete('cascade');
            $table->text('description');
            $table->string('photo_path')->nullable();
            $table->enum('status', ['pending', 'assigned', 'on_progress', 'resolved', 'rejected'])->default('pending');

            // Tambahan untuk fitur feedback dari user
            $table->integer('rating')->nullable();
            $table->text('feedback_notes')->nullable();

            $table->timestamps();  // Otomatis membuat created_at dan updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
