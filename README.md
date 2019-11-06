# Results-Logger
A shell program to log exam results in Perl 5.

# Requirements
- Strawberry Perl >5.10.0

# Usage:
Run `/perl results.pl -h` for:

```
Usage: perl ./results.pl [-v] [-s] [-r] [Subject Grade % Expected_grade Mock(%) Boundary]
Use -s option to sort by percentage, no option for alphabetical, -r for reverse for both modes
-v verbose switch is incompatible with other display switches
Use spaces for delimiters.
Fill unknown values with '.' or otherwise - exception will be thrown if args is incomplete
```
