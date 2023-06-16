<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        \App\Models\User::factory()->create([
            'name' => env('ENV_USER_NAME'),
            'email' => env('ENV_USER_EMAIL'),
            'password' => env('ENV_USER_PASSWORD'),
        ]);
    }
}
