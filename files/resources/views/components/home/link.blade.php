@props(['link', 'caption'])

<div class="grid items-center justify-center px-4">
    <a
        href="{{ $link }}"
        {{ $attributes->class([
                'text-primary-600 dark:text-dark-primary-500 dark:hover:text-dark-primary-400 hover:text-primary-700 font-medium uppercase transition-all duration-150 ease-in-out focus:underline focus:outline-none relative after:absolute after:bg-gray-600 dark:after:bg-background-1 after:-bottom-1 after:left-0 after:h-[3px] after:w-full after:origin-bottom-right after:scale-x-0 hover:after:origin-bottom-left hover:after:scale-x-100 after:transition-transform after:ease-in-out after:duration-300',
            ])->merge() }}
    >
        {{ $caption }}
    </a>
</div>
