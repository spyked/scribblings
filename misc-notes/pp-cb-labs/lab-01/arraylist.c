/*
 * PP, Laboratorul introductiv. Implementare array list.
 *
 * Implementarea este "functionala", i.e. implementeaza tipul de date
 * abstract lista (in cazul de fata de intregi):
 *
 * List a = Nil | Cons a (List a)
 *
 * respectiv functiile:
 *
 * head : List a -> a si tail : List a -> List a
 */

#include <stdio.h>
#include <stdlib.h>

/* Implementam urmatoarele operatii peste structura de date lista:
 *
 * 1. Initializare/crearea unei liste noi (new, cons)
 *
 * 2. head, tail
 *
 * 3. Accesarea elementului de pe pozitia i (unde i >= 0)
 *
 * 4. Adaugarea elementului de pe pozitia i (unde i >= 0)
 *
 * 5. Stergerea elementului de pe pozitia i (unde i >= 0)
 *
 * 6. Afisarea unei liste
 *
 * Un exercitiu util ar putea consta in implementarea ultimelor patru
 * puncte folosind doar functiile de la primele doua.
 */

/* Pentru a implementa structura de date lista pe baza array-ului,
 * trebuie sa retinem doua informatii: array-ul in sine (sau un pointer
 * catre array), si numarul de elemente continute la un moment dat in
 * array (deci indicele primei casute libere din array).
 *
 * Pentru a simplifica implementarea, presupunem ca array-ul este alocat
 * static, deci contine un numar maxim LIST_CAPACITY de elemente
 * prealocate. Astfel, adaugarea unui element nou la o lista de
 * LIST_CAPACITY elemente va intoarce o eroare.
 *
 * Ca bonus, putem considera implementarea unei liste care foloseste
 * alocare dinamica si mareste capacitatea disponibila atunci cand este
 * depasit maximul disponibil.
 */

#define LIST_CAPACITY 42

struct arraylist {
        long storage[LIST_CAPACITY];
        unsigned n_elems;
};

/* Pentru a păstra abordarea "functionala", consideram ca orice functie
 * trebuie sa intoarcă un pointer catre un struct arraylist, sau
 * valoarea speciala ERROR in cazul unei erori (deoarece vrem sa putem
 * distinge intre lista vida si un cod de eroare).
 */
#define ERROR ((struct arraylist *)(-1))

/* Initializarea unui arraylist */
struct arraylist *arraylist_new(void)
{
        struct arraylist *l = malloc(sizeof(struct arraylist));
        l->n_elems = 0;

        return l;
}


struct arraylist *arraylist_cons(long n, struct arraylist *l)
{
        if (l->n_elems >= LIST_CAPACITY)
                return ERROR;

        l->storage[l->n_elems++] = n;
        return l;
}

long arraylist_head(struct arraylist *l)
{
        if (l->n_elems == 0)
                return (long) ERROR;
        return l->storage[l->n_elems - 1];
}

struct arraylist *arraylist_tail(struct arraylist *l)
{
        if (l->n_elems == 0)
                return ERROR;
        l->n_elems--;
        return l;
}

long arraylist_get(unsigned i, struct arraylist *l)
{
        if (i == 0)
                return arraylist_head(l);
        return arraylist_get(i - 1, arraylist_tail(l));
}

struct arraylist *arraylist_insert(long n, unsigned i, struct arraylist *l)
{
        long new_head;
        struct arraylist *rec;

        if (i == 0)
                return arraylist_cons(n, l);

        new_head = arraylist_head(l);
        rec = arraylist_insert(n, i - 1, arraylist_tail(l));

        return arraylist_cons(new_head, rec);
}

struct arraylist *arraylist_remove(unsigned i, struct arraylist *l)
{
        long new_head;
        struct arraylist *rec;

        if (i == 0)
                return arraylist_tail(l);

        new_head = arraylist_head(l);
        rec = arraylist_remove(i - 1, arraylist_tail(l));

        return arraylist_cons(new_head, rec);
}

# if 0
/*
 * XXX: Implementare imperativa ale functiilor 3-6 din
 * arraylist. Teoretic orice operatie pe lista poate fi implementata
 * folosind functiile 1-2.
 */

long arraylist_get(unsigned i, struct arraylist *l)
{
        if (l->n_elems <= i)
                return (long) ERROR;

        return l->storage[l->n_elems - i - 1];
}

struct arraylist *arraylist_insert(long n, unsigned i, struct arraylist *l)
{
        unsigned k;

        if (l->n_elems <= i)
                return ERROR;

        if (l->n_elems + 1 > LIST_CAPACITY)
                return ERROR;

        /* Trebuie sa "facem loc" pentru i */
        for (k = l->n_elems - 1; k > l->n_elems - i - 1; k--)
                l->storage[k + 1] = l->storage[k];
        l->n_elems++;
        l->storage[l->n_elems - i - 1] = n;

        return l;
}

/* Stergerea de elemente necesita O(n) operatii in cazul cel mai
 * defavorabil. In cazul de fata, definim o functie care "muta" lista cu
 * un element la stanga, incepand de la indicele i.
 */
struct arraylist *arraylist_remove(unsigned i, struct arraylist *l)
{
        int k;

        if (l->n_elems <= i)
                return ERROR;

        l->n_elems--;
        for (k = l->n_elems - i; k < l->n_elems; k++)
                l->storage[k] = l->storage[k + 1];

        return l;
}
#endif

void arraylist_print(struct arraylist *l)
{
        int i;
        for (i = l->n_elems - 1; i >= 0; i--)
                printf("%ld ", l->storage[i]);
        printf("\n");
}

int main(void)
{
        struct arraylist *l;

        /* Test:
         * - Creeaza un array nou.
         *
         * - Adauga pe rand elementele 1, 2, 3, 4.
         *
         * - Adauga elementul 5 pe pozitia 2.
         *
         * - Ia capul listei
         *
         * - Ia coada listei
         *
         * - Sterge elementul de pe pozitia 2.
         *
         * - Sterge elementul de pe pozitia 0.
         */
        l = arraylist_new();
        l = arraylist_cons(1, arraylist_cons(2, arraylist_cons(3, l)));
        l = arraylist_cons(4, l);
        printf("l = "); arraylist_print(l);
        l = arraylist_insert(5, 2, l);
        printf("after inserting at pos 2, l = "); arraylist_print(l);
        printf("head(l) = %ld\n", arraylist_head(l));
        l = arraylist_tail(l);
        printf("l = tail(l) = "); arraylist_print(l);
        l = arraylist_remove(2, l);
        printf("removed l[2]; l = "); arraylist_print(l);
        l = arraylist_remove(0, l);
        printf("removed l[0]; l = "); arraylist_print(l);
        free(l);

        /* Discutie: TODO
         *
         */

        /* Bonus:
         *
         * - Concatenarea a doua liste
         *
         * - Alocarea "on-demand" a spatiului pentru liste atunci cand e
         *   depasita capacitatea.
         */
        return 0;
}
