#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

static uint32_t *got_start;
static uint32_t *got_end;
static size_t got_size;

static uint32_t *got_sleep;
static uint32_t *got_system;
static uint32_t *got_puts;
static uint32_t *got_kill;

static void
get_got(void)
{
	/*
	 * 08048320 <printf@plt>:
	 * 8048320:	ff 25 00 a0 04 08    	jmp    *0x804a000
	 * 8048326:	68 00 00 00 00       	push   $0x0
	 * 804832b:	e9 e0 ff ff ff       	jmp    8048310 <_init+0x38>
	 */
	volatile uint32_t *plt_ptr = (uint32_t *)(2+(uint8_t *)puts);
	volatile uint32_t got_min = *plt_ptr;
	volatile uint32_t got_max = *plt_ptr;

#ifdef DEBUG
	printf("got-test@%x\n", *plt_ptr);
#endif
	int i;
	for (i = 0; i < 100; ++i) {
		uint8_t *plt_new = (uint8_t *)plt_ptr-i*0x10;
		if (*(plt_new+4) != 0x68) {
			/* this is not a push */
			break;
		}
		uint32_t got_offset = *(uint32_t *)plt_new;
#ifdef DEBUG
		printf("got off@%08x\n", got_offset);
#endif
		if (got_offset > got_max)
			got_max = got_offset;
		if (got_offset < got_min)
			got_min = got_offset;
	}
#ifdef DEBUG
	printf("going down\n");
#endif
	for (i = 0; i < 100; ++i) {
		uint8_t *plt_new = (uint8_t *)plt_ptr+i*0x10;
		if (*(plt_new+4) != 0x68) {
			/* this is not a push */
			break;
		}
		uint32_t got_offset = *(uint32_t *)plt_new;
#ifdef DEBUG
		printf("got off@%08x\n", got_offset);
#endif
		if (got_offset > got_max)
			got_max = got_offset;
		if (got_offset < got_min)
			got_min = got_offset;
	}
	printf("GOT is between %08x-%08x\n", got_min, got_max);
	got_start = (uint32_t *)got_min;
	got_end = (uint32_t *)got_max;
	got_size = got_max-got_min;
}

static void
print_got(void)
{
	uint32_t *p = got_start;
	int cnt = 0;
	while (p <= got_end) {
		printf("GOT[%02d(0x%p)] = %08x\n", cnt, p, *p);
		++cnt;
		++p;
	}
	fprintf(stdout, "GOT-end\n");
}

static int
my_first_diff(uint8_t *a, uint8_t *b, size_t size)
{
	int i;
	for (i = 0; i < size; i += 4, a += 4, b += 4)
		if (*(uint32_t *)a != *(uint32_t *)b)
			return i;
	return -1;
}

#define MAX_GOT_SZ 1024

static uint32_t *
get_got_for_sleep(void)
{
	/* Use this as an example */
	uint8_t old_got[MAX_GOT_SZ];
	uint8_t new_got[MAX_GOT_SZ];
	int ret;

	memcpy(old_got, got_start, got_size);
	/* avoid memcpy */
	print_got();
	memcpy(old_got, got_start, got_size);

	sleep(1);

	print_got();
	memcpy(new_got, got_start, got_size);
	ret = my_first_diff(old_got, new_got, got_size);
	if (ret < 0) {
		fprintf(stdout, "Failed to find sleep\n");
		exit(-1);
	}
	got_sleep = &got_start[ret>>2];
	printf("sleep@got %p\n", got_sleep);
	return got_sleep;
}

static uint32_t *
get_got_for_kill(void)
{
	/* TODO */

	printf("kill@got %p\n", got_kill);
	return got_kill;
}

static uint32_t *
get_got_for_puts(void)
{
	/* TODO */

	//got_puts = &got_start[ret>>2];
	printf("puts@got %p\n", got_puts);
	return got_puts;
}

static uint32_t *
get_got_for_system(void)
{
	/* TODO */

	//got_system = &got_start[ret>>2];
	printf("system@got %p\n", got_system);
	return got_system;
}

/* Do not modify this function,
 * call this function after having fun with the GOT table
 */
static void
my_func(void)
{
	sleep("This should go to stdout\n");
	kill("uname -a");
}

int
main(void)
{
	int i;

	get_got();
	print_got();

	get_got_for_sleep();
	get_got_for_kill();
	get_got_for_puts();
	get_got_for_system();

	printf("Replacing sleep with puts %08x -> %08x\n", *got_sleep, *got_puts);
	*got_sleep = *got_puts;

/* TODO */
	printf("Replace kill with system %08x -> %08x\n", *got_sleep, *got_puts);

	my_func();
	return 0;
}
