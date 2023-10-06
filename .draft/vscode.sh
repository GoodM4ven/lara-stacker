# Check if VSC is installed
found_vsc=false
if command -v code &>/dev/null; then
    found_vsc=true
elif command -v codium &>/dev/null; then
    found_vsc=true
fi

# TODO run the projects using it