#!/bin/bash

gitlabProjects="./gitlab.projects"

if [[ ! -f "${gitlabProjects}" ]]; then printf "" > "${gitlabProjects}"; fi

create-new-project() {
    # ${1} : project uid
    read -p "> [project name]:" GITLAB_PROJECT_NAME
    read -p "> [project id]:" GITLAB_PROJECT_ID
    projectAlreadyExist=$(awk -F/ '$1 == "=>'${1}':" {print "exist"; exit 0}' ${gitlabProjects})
    if [[ -z "${projectAlreadyExist}" ]]; then
        printf "==> Create new gitlab project configuration..."
        printf "\n" >> "${gitlabProjects}"
        printf "=>${1}:\n" >> "${gitlabProjects}"
        printf "${1}_project_name=${GITLAB_PROJECT_NAME}\n" >> "${gitlabProjects}"
        printf "${1}_project_id=${GITLAB_PROJECT_ID}\n" >> "${gitlabProjects}"
        printf "<=\n" >> "${gitlabProjects}"
        else
            printf "==> Update [${1}] gitlab project configuration..." 
            sed -i -E 's/'"(${1}_project_name=).*"'/\1'"${GITLAB_PROJECT_NAME//\//\\/}"'/g' "${gitlabProjects}"
            sed -i -E 's/'"(${1}_project_id=).*"'/\1'"${GITLAB_PROJECT_ID//\//\\/}"'/g' "${gitlabProjects}"
    fi
    if [[ $? == 1 ]]; then printf "Failed!\n"; exit 1; else printf "Done ✔️\n"; fi
}

remove-project() {
    # ${1} : project uid
    projectFound=$(awk -F/ '$1 == "=>'${1}':" {print "exist"; exit 0}' ${gitlabProjects})
    if [[ ! -z "${projectFound}" ]]; then
        read -p "Remove this [${1}] gitlab configuration? [y/n]:" response 
        case "${response}" in
        [yY]*)
            printf "==> Remove [${1}] gitlab configuration..."
            sed -i -E '/=>'${1}':/,/<=/d' "${gitlabProjects}"
            if [[ $? == 1 ]]; then printf "Failed!\n"; exit 1; else printf "Done ✔️\n"; fi
        ;;
    esac
        else
            printf "Error! Project not found!\n"
    fi
}

remove-all-projects() {
    read -p "Remove all projects gitlab configurations? [y/n]:" response
    case "${response}" in
        [yY]*)
        printf "==> Remove all gitlab projects configuration..."
        printf "" > "${gitlabProjects}"
        if [[ $? == 1 ]]; then printf "Failed!\n"; exit 1; else printf "Done ✔️\n"; fi
    esac
}

help() {
    printf "Invalid command!\n"
    printf "Possible options:\n"
    printf "  --new {project_uid}\n"
    printf "  --rm {project_uid}\n"
    printf "  --remove-all\n"
}

params=()

for arg in "$@"; do
    params+=("$arg")
done

for i in "${!params[@]}"; do
    case "${params[$i]}" in
        --new)
        if [[ -z "${params[$i + 1]}" ]]; then help; exit 1; fi
        create-new-project "${params[$i + 1]}"
        ;;
        --rm)
        if [[ -z "${params[$i + 1]}" ]]; then help; exit 1; fi
        remove-project "${params[$i + 1]}"
        ;;
        --remove-all)
        remove-all-projects
        ;;
    esac
done