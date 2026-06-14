<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Kumpulkan semua data user ke dalam satu variabel array besar
        $users = [
            [
                'name' => 'Bagus Faaza',
                'email' => 'admin@siptu.test',
                'password' => bcrypt('admin123'),
                'role' => 'admin'
            ],
            [
                'name' => 'Muhammad Iqbal',
                'email' => 'staff@siptu.test',
                'password' => bcrypt('staff123'),
                'role' => 'staff'
            ],
            [
                'name' => 'Elsa Ajeng',
                'email' => 'elsa@siptu.test',
                'password' => bcrypt('user123'),
                'role' => 'user'
            ],
            [
                'name' => 'Charlene Ridsianeva',
                'email' => 'charlene@siptu.test',
                'password' => bcrypt('user123'),
                'role' => 'user'
            ]
        ];

        // Masukkan datanya satu per satu secara otomatis menggunakan looping
        foreach ($users as $user) {
            User::create($user);
        }
    }
}
