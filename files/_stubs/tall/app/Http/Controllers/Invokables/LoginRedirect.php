<?php

namespace App\Http\Controllers\Invokables;

use Illuminate\Http\Request;

class LoginRedirect extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request)
    {
        return redirect()->back();
    }
}
