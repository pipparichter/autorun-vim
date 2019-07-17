" Variables -----------------------------------------

" Stores project information in the form 
" {project_name:['path':path,'files':[file1, file2, file3,...]}, ...}
let g:cpp_projects = {} 

" Settings (adjustable) ------------------------------

let g:add_buffer_when_making_new_project = 1
let g:current_project = 

" Functions -------------------------------------------

function Run()
    if 
        call RunCPP()
    elseif
        call RunPython()
    else
        echo "This filetype is not supported"
        return 0
endfunction


function RunPython()
    " Save the open buffer
    w
    " Open a new window and run the current file
    ! "gnome-terminal --window --  python %"
endfunction


function RunCPP()
    let l:working_directory = g:cpp_projects[s:current_project][0]
    " Save the open buffer
    w
    " Open a new window and compile the current CPP project
    ! "gnome-terminal --window -- g++ "
    echo "Compilation successful"
    ! "gnome-terminal --window --working-directory " + l:working_directory + " -- sh -c './a.out ; bash'"
endfunction


function MakeCPPProject(project_name)
    " Check to see whether or not the project already exists
    if get(g:cpp_projects, a:project_name) == 0
        if g:add_buffer_when_making_project == 1
            " Add the current buffer to the new project
            g:cpp_projects[a:project_name] = %
        elseif g:add_buffer_when_making_project == 0:
            " If the setting is off, make the current project an empty string
            g:cpp_projects[a:project_name] = ""
        else
            echo "There may be something wrong with your settings. Make sure g:add_bugger_when_making_project is either 0 or 1."
            return 0
        endif
    else
        echo "Project already exists. Use :RemoveCPPProject to remove from g:cpp_projects."
        return 0
    endif

    return 1

endfunction


" Accepts an undefined number of arguments in the form of filenames (if the
" file is in the project home directory) or filepaths (preferred)
function AddCPPProject(...)
    let l:to_add = a:00
    " Assign a copy of the current files in project to the variable
    " current_files
    let l:current_files = g:cpp_projects[g:current_project][:]
    
    for file in l:to_add
        if count(l:current_files, file) == 0
            let l:current_files = add(l:current_files, file)
    endfor

    let g:cpp_projects[g:current_project] = l:current_files + l:to_add


endfunction


" Commands --------------------------------------------

command RunPython call RunPython()
command RunCPP call RunCPP()
command AddToCPPProject call AddToCPPProject()

