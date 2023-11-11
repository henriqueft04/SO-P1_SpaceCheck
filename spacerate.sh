#!/bin/bash

# Inicialize as variáveis ​​de opção para desativado
reverse=0
alphabetical=0

files=() # array para armazenar os nomes dos arquivos de entrada

while getopts "ra" opt; do
    case $opt in
        r)
        reverse=1               # reverse ativo
        ;;
        a)
        alphabetical=1          # alphabetical ativo
        ;;
    esac
done
shift $((OPTIND -1))

# Verificar se os argumentos fornecidos são ficheiros
for file in "$@"; do
    if [ -f "$file" ]; then
        files+=("$file")
    else
        echo "File $file does not exist, try again"
    fi
done

# Verifique se o número de arquivos fornecidos é exatamente 2
if [ ${#files[@]} -ne 2 ]; then
    echo "This script requires exactly two input files to compare."
    exit 1
fi

# Crie um array associativo para armazenar as informações do arquivo mais antigo
declare -A folders_older
while read -r line; do
    if [[ "$line" != *"SIZE"* ]]; then
        folder_older=$(echo "$line" | awk '{print $2}')
        size_older=$(echo "$line" | awk '{print $1}')
        
        folders_older["$folder_older"]=$size_older
    fi
done < "${files[1]}"

output=()   # array para armazenar as informações de saída

while read -r line; do
    if [[ "$line" == *"SIZE"* ]]; then
        continue                            # saltar a linha de cabeçalho
    fi

    size_new=$(echo "$line" | awk '{print $1}')  # armazenar o tamanho da pasta
    folder_new=$(echo "$line" | awk '{print $2}')   # armazenar o nome da pasta

    if [[ ! "${folders_older[$folder_new]+_}" ]]; then
        output+=("$size_new $folder_new NEW")           # verificar se o array com os folders antigos tem a pasta, se tiver adiciona ao output com o status NEW
    else
        size_older=${folders_older[$folder_new]}
        unset "folders_older[$folder_new]"          

        if [ "$size_new" -gt "$size_older" ]; then      # verificar se o tamanho da pasta nova é maior que a pasta antiga
            size_diff=$((size_new - size_older))
            output+=("$size_diff $folder_new")
        elif [ "$size_new" -lt "$size_older" ]; then        # verificar se o tamanho da pasta nova é menor que a pasta antiga
            size_diff=$((size_older - size_new))
            output+=("-$size_diff $folder_new")
        else                                                # verificar se o tamanho da pasta nova é igual que a pasta antiga
            output+=("0 $folder_new")
        fi
    fi
done < "${files[0]}"

# Verifique se há pastas removidas no arquivo mais antigo
for folder_older in "${!folders_older[@]}"; do
    size_older=${folders_older[$folder_older]}             
    output+=("-$size_older $folder_older REMOVED")      # adiciona ao output com o status REMOVED as pastas removidas
done

# Imprimir o array de saída de acordo com as opções
if [ $reverse -eq 1 ]; then
    if [ $alphabetical -eq 1 ]; then
        printf "%s %s %s\n" "SIZE" "NAME" 
        printf "%s\n" "${output[@]}" | sort -r | awk '{printf "%s %s %s\n", $1, $2, $3}'            
    else
        printf "%s %-s %s\n" "SIZE" "NAME" 
        printf "%s\n" "${output[@]}" | tac | awk '{printf "%s %s %s\n", $1, $2, $3}'
    fi
else
    if [ $alphabetical -eq 1 ]; then
        printf "%s %s %s\n" "SIZE" "NAME"
        printf "%s\n" "${output[@]}" | sort | awk '{printf "%s %s %s\n", $1, $2, $3}'
    else
        printf "%s %s\n" "SIZE" "NAME" 
        printf "%s\n" "${output[@]}" | awk '{printf "%s %s %s\n", $1, $2, $3}'
    fi
fi
