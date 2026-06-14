<?php

namespace Tests\Feature;

use App\Models\Facility;
use App\Models\Report;
use App\Models\Room;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SiptuWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_report_assignment_task_upload_and_notification_workflow(): void
    {
        Storage::fake('public');

        $reporter = User::factory()->create(['role' => 'user']);
        $admin = User::factory()->create(['role' => 'admin']);
        $staff = User::factory()->create(['role' => 'staff', 'nip' => 'STAFF-001']);
        $room = Room::create([
            'building_name' => 'Gedung A',
            'room_name' => 'Ruang Sidang',
        ]);
        $facility = Facility::create([
            'room_id' => $room->id,
            'name' => 'Proyektor Ruang Sidang',
            'category' => 'Fasilitas Belajar',
            'code' => 'PRJ-A-001',
        ]);

        Sanctum::actingAs($reporter);
        $reportResponse = $this->post('/api/reports', [
            'facility_id' => $facility->id,
            'title' => 'Proyektor buram',
            'description' => 'Tampilan proyektor tidak fokus.',
            'location' => 'Gedung A, Ruang Sidang',
            'photos' => [UploadedFile::fake()->image('before.jpg')],
        ]);

        $reportResponse
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.category', 'Fasilitas Belajar')
            ->assertJsonCount(1, 'data.photos');

        $reportId = $reportResponse->json('data.id');

        Sanctum::actingAs($admin);
        $assignmentResponse = $this->postJson("/api/reports/{$reportId}/assign", [
            'staff_id' => $staff->id,
            'admin_notes' => 'Periksa lensa dan lampu.',
            'deadline_at' => now()->addDay()->toISOString(),
        ]);

        $assignmentResponse
            ->assertCreated()
            ->assertJsonPath('data.staff.id', $staff->id)
            ->assertJsonPath('data.status', 'assigned');

        $taskId = $assignmentResponse->json('data.id');

        Sanctum::actingAs($staff);
        $updateResponse = $this->post("/api/tasks/{$taskId}/updates", [
            'status' => 'resolved',
            'notes' => 'Lensa dibersihkan dan lampu diganti.',
            'photos' => [UploadedFile::fake()->image('after.jpg')],
        ]);

        $updateResponse
            ->assertCreated()
            ->assertJsonPath('data.status', 'resolved')
            ->assertJsonCount(1, 'data.photos');

        $this->assertDatabaseHas('reports', ['id' => $reportId, 'status' => 'resolved']);
        $this->assertDatabaseHas('tasks', ['id' => $taskId, 'status' => 'resolved']);
        $this->assertDatabaseHas('user_notifications', [
            'user_id' => $reporter->id,
            'type' => 'task.updated',
        ]);
        $this->assertDatabaseHas('user_notifications', [
            'user_id' => $staff->id,
            'type' => 'task.assigned',
        ]);
    }

    public function test_staff_cannot_update_another_staff_task(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $reporter = User::factory()->create(['role' => 'user']);
        $assignedStaff = User::factory()->create(['role' => 'staff', 'nip' => 'STAFF-001']);
        $otherStaff = User::factory()->create(['role' => 'staff', 'nip' => 'STAFF-002']);
        $room = Room::create(['building_name' => 'Gedung A', 'room_name' => 'Koridor']);
        $facility = Facility::create([
            'room_id' => $room->id,
            'name' => 'Lampu Koridor',
            'category' => 'Penerangan',
            'code' => 'LMP-A-001',
        ]);
        $report = Report::create([
            'ticket_number' => 'TIK-TEST-001',
            'user_id' => $reporter->id,
            'facility_id' => $facility->id,
            'title' => 'Lampu mati',
            'description' => 'Lampu mati total.',
            'location' => 'Gedung A',
            'category' => 'Penerangan',
        ]);
        $task = $report->task()->create([
            'task_number' => 'TGS-TEST-001',
            'assigned_by' => $admin->id,
            'staff_id' => $assignedStaff->id,
        ]);

        Sanctum::actingAs($otherStaff);

        $this->postJson("/api/tasks/{$task->id}/updates", [
            'status' => 'on_progress',
            'notes' => 'Mencoba memperbarui.',
        ])->assertForbidden();
    }

    public function test_notification_test_requires_a_registered_device(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        Sanctum::actingAs($user);

        $this->postJson('/api/notifications/test')
            ->assertUnprocessable()
            ->assertJsonPath('registered_devices', 0);
    }
}
