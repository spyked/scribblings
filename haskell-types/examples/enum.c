#include <stdio.h>

typedef enum {
	Apples = 1,
	Pears = 2,
	Oranges = 3,
	Tomatoes = 4
} fruit_e;

int main(void)
{
	fruit_e fr = Tomatoes;

	printf("fruit: %d\n", (int) fr);

	return 0;
}
