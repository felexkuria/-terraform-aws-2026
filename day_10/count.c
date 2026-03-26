#include <stdio.h>

int main(void)
{
    // 1. Our Array of Strings (The 'Input Terminal')
        char *user_names[] = {"neo", "matrix", "morpheus"};

    // 2. The 'length' function (In C, we calculate this manually)
    int count = 3;

    // 3. The 'For' Loop
    // int i = 0 is our starting point (the first locker)
    // i < count is our boundary (the end of the row)
    // i++ is our step (move to the next locker)
    for (int i = 0; i < count; i++)
    {
        // 4. The Array Lookup: user_names[i]
        printf("Creating IAM User: %s\n", user_names[i]);
    }
}