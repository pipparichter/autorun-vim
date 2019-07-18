" Variables -----------------------------------------
 
" Stores project information in the form 
" {project_name:['path':path,'files':[file1, file2, file3,...]}, ...}
let g:cpp_projects = {}
let g:current_project = ""

" The list of CPP projects was loaded into the projects.txt in the following
" format:
" {project name} : {path} :: {file1} ::: {file2} ::: {file3}...
" {project name} : ...
function! LoadCPPProjects()
    let l:dictionary = {}
    " Only try loading projects.txt if the file exists
    if findfile("projects.txt", expand("~/.vim")) == expand("~/.vim/projects.txt")
        " readfile() automatically splits the file into a list, one item per line
        " in file
        let l:split_by_project = readfile(expand("~/vim/projects.txt"))
        for project in l:split_by_project
            let l:first = split(project, " : ")
            let l:name = l:first[0]
            let l:dictionary[l:name] = {}

            let l:second = split(l:first[1], " :: ")
            let l:path = l:second[0]
            let l:dictionary[l:name]["path"] = l:path

            let l:third = split(l:second[1], " ::: ")
            let l:files = l:third
            let l:dictionary[l:name]["files"] = l:files
        endfor
    endif

    return l:dictionary

endfunction


function! SaveCPPProjects()
    let l:line_list = []
    for project in keys(g:cpp_projects)
        let l:project_string = ""
        let l:project_string += project + " : "
        let l:project_string += g:cpp_projects[project]["path"] + " :: "
        for item in g:cpp_projects[project]["files"]
            let l:project_string += item + " ::: "
        endfor
        add(l:line_list, l:project_string)
    endfor
    call writefile(l:line_list, expand("~/.vim/projects.txt"))

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
        let g:cpp_projects[a:project_name] = {"path":"", "files":[]}
        
        " Set the project path to the current working directory
        let l:path = expand(getcwd()) 
        let g:cpp_projects[a:project_name]["path"] = l:path


        if g:add_buffer_when_making_project == 1
            " Save the current buffer
            w
            " Add the current buffer to the new project
            let let g:cpp_projects[a:project_name]["files"] += [expand("%")] 
        elseif g:add_buffer_when_making_project == 0
            " If the setting is off, do not add the current buffer to the new
            " project (not a necessary command, there for readability)
            let g:cpp_projects[a:project_name]["files"] = []
        else
            echo "There may be something wrong with your settings. Make sure g:add_buffer_when_making_project is either 0 or 1."
        endif
    else
        echo "Project already exists. Use :RemoveCPPProject to remove from g:cpp_projects."
    endif

endfunction


" Accepts an undefined number of arguments in the form of relative file paths.
function! AddToCPPProject(...)
    if g:current_project == ""
        echo "Please specify youre current project using the :SetCurrentCPPProject command"
    else
        "Save the current buffer
        w

        let l:to_add = a:00
        let l:current_files = g:cpp_projects[g:current_project]["files"]
        let l:paths_to_add = []

        for item in l:to_add
            " Make sure the file being added isn't already in the list of
            " files
            if count(l:current_files, item) == 0
                let l:paths_to_add += [expand(item)]
            endif
        endfor

        let g:cpp_projects[g:current_project]["files"] += l:paths_to_add
    endif

endfunction


function! SetCurrentProject(project_name)
    if get(g:cpp_projects, a:project_name) != 0
        let g:current_project = a:project_name
    else
        echo "Not a valid project name. Use :ShowCPPProjects to view a list of existing projects."
    endif
    
endfunction


function! ShowCPPProjects()
    for project in keys(g:cpp_projects)
        echo "- " + project

        let l:project_files = g:cpp_projects[project]["files"]
        for item in l:project_files
            echo "--- " + item
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

