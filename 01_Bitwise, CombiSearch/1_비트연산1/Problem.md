```cpp
#include <stdio.h>
 
char op[7][4] = {"?", "~", "&", "|", "^", "<<", ">>"};
 
int main(){
    printf("%s\n",     op[0]);               /// (1)
    printf("%s%s\n",   op[0], op[0]);        /// (2)
    printf("%s\n",     op[0]);               /// (3)
    printf("%s%s%s\n", op[0], op[0], op[0]); /// (4)
    printf("%s%s%s\n", op[0], op[0], op[0]); /// (5)
    printf("%s%s\n",   op[0], op[0]);        /// (6)
    printf("%s%s%s\n", op[0], op[0], op[0]); /// (7)
    printf("%s%s\n",   op[0], op[0]);        /// (8)
    printf("%s\n",     op[0]);               /// (9)
    printf("%s%s\n",   op[0], op[0]);        /// (10)
    
    return 0;
}
```
