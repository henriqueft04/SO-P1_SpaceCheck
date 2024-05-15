# Bash Scripting for Storage Management

## How to Run
To monitor and manage disk space usage, execute the following commands:

The options for spacecheck.sh can be:
* **-n [regex]** : Include files that match the regex;
* **-d [date]** : Include files modified after the specified date;
* **-s [size]** : Include files larger than the specified size;
* **-r** : Sort results in reverse order;
* **-a** : Sort results alphabetically;
* **-l [number]** : Limit the output to a number of lines.

## Example
* ./spacecheck.sh -n ".*sh" -r ../yourfolder
* ./spacerate.sh output_day1 output_day2 -a


## Evaluation
18

## Authors
* [Henrique Teixeira] - [@henriqueft04]
* [Martim Santos] - [@martimsoutooo]

---

Universidade de Aveiro, Ano letivo 2023/2024
