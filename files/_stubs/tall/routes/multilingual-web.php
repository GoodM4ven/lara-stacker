<?php

use App\Http\Controllers\HomeController;
use App\Http\Controllers\LoginRedirect;
use Illuminate\Support\Facades\Route;
use Mcamara\LaravelLocalization\Facades\LaravelLocalization;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', [HomeController::class, 'home'])->name('home');

Route::middleware(['guest'])->group(function () {
    Route::get('/login', LoginRedirect::class)->name('login');
});

// ? Prefix routes with locales
Route::group([
    'prefix' => LaravelLocalization::setLocale(),
    'middleware' => [
        'localeSessionRedirect',
    ],
], function () {
    // ? Translate routes
    Route::middleware('localize')->group(function () {
        // ? Only for guests
        Route::group(['middleware' => 'guest'], function () {
            // // * Login
            // Route::get(LaravelLocalization::transRoute('routes.login'), Login::class)->name('login');
        });

        // ? Only for users
        Route::group(['middleware' => 'auth'], function () {
            // // * Logout
            // Route::get(LaravelLocalization::transRoute('routes.logout'), Logout::class)->name('logout');
        });

        // // * Home
        // Route::view('/', 'home');
    });
});
