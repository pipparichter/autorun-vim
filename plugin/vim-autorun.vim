" Variables -----------------------------------------
 
" Stores project information in the form 
" {project_name:['path':path,'files':[file1, file2, file3,...]}, ...}
let g:cpp_projects = {}


" The list of CPP projects was loaded into the projects.txt in the following
" format:
" {project name} : {path} :: {file1} ::: {file2} ::: {file3}...
" {project name} : ...
function! LoadCPPProjects()
    let l:dictionary = {}
    " Only try loading projects.txt if the file exists
    if findfile("projects.txt", "~/.vim") = "~/.vim/projects.txt"
        " readfile() automatically splits the file into a list, one item per line
        " in file
        let l:split_by_project = readfile("~/.vim/projects.txt")
        for project in l:split_by_project
            let l:first = split(project, " : ")
            let l:name = l:first[0]
            l:dictionary[l:name] = {}

            let l:second = split(l:first[1], " :: ")
            let l:path = l:second[0]
            l:dictionary[l:name]["path"] = l:path

            let l:third = split(l:second[1], " ::: ")
            let l:files = l:third
            l:dictionary[l:name]["files"] = l:files
        endfor
    endif

    return l:dictionary

endfunction


function! SaveCPPProjects()
    l:line_list = []
    for project in keys(g:cpp_projects)
        l:project_string = ""
        l:project_string += project + " : "
        l:project_string += g:cpp_projects[project]["path"] + " :: "
        for item in g:cpp_projects[project]["files"]
            l:project_string += item += " ::: "
        endfor
        add(l:line_list, l:project_string)
    endfor
    writefile(l:line_list, "~/.vim/projects.txt")

endfunction


augroup load_and_write_projects
    autocmd!
    autocmd BufWinEnter * let g:cpp_projects = LoadCPPProjects()
    autocmd BufWinLeave * call SaveCPPProjects() 
augroup END

" Settings (adjustable) ------------------------------

let g:add_buffer_when_making_new_project = 1
let s:current_project = ""

" Functions -------------------------------------------

function! Run()
    let l:match_cpp = len(matchstr("%", "*.cpp\|*.hpp\|*.h")) 
    let l:match_py = len(matchstr("%", "*.py"))
    
    if l:match_cpp > 0    
        call RunCPP()
    elseif l:match_py >0
        call RunPython()
    else
        echo "Filetype is not supported."
        return 0
    endif
endfunction


function! RunPython()
    " Save the open buffer
    w
    " Open a new window and run the current file
    ! "gnome-terminal --window --  python " + expand("%")

endfunction


function! RunCPP()
    if len(s:current_project) == 0
        echo "Please specify your current project using the :SetCurrentProject command"
    else
        let l:current_project = g:cpp_projects[s:current_project]
        let l:working_directory = l:current_project['path']
        let l:project_files = join(l:current_project['files'], " ")

        if len(l:project_files) == 0
            echo "Your set project is empty. Use the :AddToProject command to add files to the current project."
        else
            " Save the open buffer
            w
            " Open a new window and compile the current CPP project
            ! "gnome-terminal --window -- g++ " + join(l:project_files, " ")
            echo "Compilation successful"
            " Run the compiled file
            ! "gnome-terminal --window --working-directory " + l:working_directory + " -- sh -c './a.out ; bash'"
        endif
    endif

endfunction


function! MakeCPPProject(project_name)
    " Check to see whether or not the project already exists
    if get(g:cpp_projects, a:project_name) == 0
        " Add a new project to cpp_projects
        g:cpp_projects[a:project_name] = {"path":"", "files":[]}
        
        let l:files = g:cpp_projects[a:project_name]["files"]
        let l:path = g:cpp_projects[a:project_name]["path"]
        " Set the project path to the current working directory
        l:path = ! "cd .." 

        if g:add_buffer_when_making_project == 1
            " Add the current buffer to the new project
            l:files += [expand("%")] 
        elseif g:add_buffer_when_making_project == 0:
            " If the setting is off, do not add the current buffer to the new
            " project
        else
            echo "There may be something wrong with your settings. Make sure g:add_buffer_when_making_project is either 0 or 1."
        endif
    else
        echo "Project already exists. Use :RemoveCPPProject to remove from g:cpp_projects."
    endif

endfunction


" Accepts an undefined number of arguments in the form of filenames (if the
" file is in the project home directory) or filepaths (preferred)
function! AddToCPPProject(...)
    if len(g:current_project) == 0
        echo "Please specify youre current project using the :SetCurrentCPPProject command"
    else
        "Save the current buffer
        w

        let l:to_add = a:00
        " Assign a copy of the current files in project to the variable
        " current_files
        let l:current_files = g:cpp_projects[g:current_project][:]
    
        for file in l:to_add
            if count(l:current_files, file) == 0
                let l:current_files = add(l:current_files, file)
            endif
        endfor

        let g:cpp_projects[g:current_project] = l:current_files + l:to_add
    endif

endfunction


function! SetCurrentProject(project_name)
    if get(g:cpp_projects, a:project_name) != 0
        s:current_project = a:project_name
    else
        echo "Not a valid project name. Use :ShowCPPProjects to view a list of existing projects."
    endif
    
endfunction


function! ShowCPPProjects()
    for project in g:cpp_projects
        echo "- " + project

        let l:project_files = g:cpp_projects[project]["files"]
        for file in l:project_files
            echo "--- " + file
        endfor
    endfor

endfunction


" Commands --------------------------------------------
command RunCPP call RunCPP()
command -nargs=* AddToCPPProject call AddToCPPProject(<args>)
command ShowCPPProjects call ShowCPPProjects()
command -nargs=1 SetCurrentProject call SetCurrentProject(<args>)
command -nargs=1 MakeCPPProject call MakeCPPProject(<args>)
command Run call Run()


" Mappings --------------------------------------------

