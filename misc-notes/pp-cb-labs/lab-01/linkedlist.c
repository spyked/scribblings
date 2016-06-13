/*
 * PP, Laboratorul introductiv. Implementare linked list.
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

/* Prin conventie, tipul de date abstract lista este reprezentat
 * printr-o pereche de doua elemente:
 *
 * - Elementul din capul listei, si
 *
 * - O referinta (in cazul C, un pointer) catre restul listei.
 *
 * De asemenea, tipul de date lista mai conține o valoare speciala, care
 * denotă lista vida.
 *
 * In cazul C, perechea de mai sus se mapeaza pe structura:
 */

struct linkedlist {
        long value;
        struct linkedlist *next;
};

/* De asemenea, putem considera ca valoarea listei vide este NULL.
 *
 * Pentru a păstra abordarea "functionala", consideram ca orice functie
 * trebuie sa intoarcă un pointer catre un struct linkedlist, sau
 * valoarea speciala ERROR in cazul unei erori (deoarece vrem sa putem
 * distinge intre lista vida si un cod de eroare).
 */

#define ERROR ((struct linkedlist *)(-1))

/* Nota: manipularea linkedlist se bazeaza in mare masura pe gestiunea
 * la run-time a memoriei, deci trebuie sa fim foarte atenti la
 * malloc/free!
 */
struct linkedlist *linkedlist_new(void)
{
        return NULL;
}

struct linkedlist *linkedlist_cons(long n, struct linkedlist *l)
{
        struct linkedlist *new = malloc(sizeof(struct linkedlist));
        new->value = n;
        new->next = l;

        return new;
}

long linkedlist_head(struct linkedlist *l)
{
        if (l == NULL)
                return (long) ERROR;

        return l->value;
}

struct linkedlist *linkedlist_tail(struct linkedlist *l)
{
        struct linkedlist *ret;
        if (l == NULL)
                return ERROR;
        
        ret = l->next;
        free(l);

        return ret;
}

long linkedlist_get(unsigned i, struct linkedlist *l)
{
        if (i == 0)
                return linkedlist_head(l);
        return linkedlist_get(i - 1, linkedlist_tail(l));
}

struct linkedlist *linkedlist_insert(long n, unsigned i, struct linkedlist *l)
{
        long new_head;
        struct linkedlist *rec;

        if (i == 0)
                return linkedlist_cons(n, l);

        new_head = linkedlist_head(l);
        rec = linkedlist_insert(n, i - 1, linkedlist_tail(l));

        return linkedlist_cons(new_head, rec);
}

struct linkedlist *linkedlist_remove(unsigned i, struct linkedlist *l)
{
        long new_head;
        struct linkedlist *rec;

        if (i == 0)
                return linkedlist_tail(l);

        new_head = linkedlist_head(l);
        rec = linkedlist_remove(i - 1, linkedlist_tail(l));

        return linkedlist_cons(new_head, rec);
}


#if 0
/*
 * XXX: Implementare imperativa ale functiilor 3-6 din
 * arraylist. Teoretic orice operatie pe lista poate fi implementata
 * folosind functiile 1-2.
 */

long linkedlist_get(unsigned i, struct linkedlist *l)
{
        if (l == NULL || i < 0)
                return (long) ERROR;
        if (i == 0)
                return l->value;
        return linkedlist_get(i - 1, l->next);
}

struct linkedlist *linkedlist_insert(long n, unsigned i, struct linkedlist *l)
{
        struct linkedlist *p;
        struct linkedlist *new = malloc(sizeof(struct linkedlist));
        new->value = n;

        if (i == 0) {
                new->next = l;
                return new;
        }

        for (p = l; p != NULL; p = p->next) {
                i--;
                if (i == 0) {
                        new->next = p->next;
                        p->next = new;

                        return l;
                }
        }

        free(new);
        return ERROR;
}

struct linkedlist *linkedlist_remove(unsigned i, struct linkedlist *l)
{
        struct linkedlist *p;

        if (l == NULL || i < 0)
                return ERROR;
        if (i == 0) {
                struct linkedlist *ret = l->next;
                free(l);

                return ret;
        }

        for (p = l; p != NULL; p = p->next) {
                i--;
                if (i == 0) {
                        struct linkedlist *rem = p->next;
                        if (rem == NULL)
                                return ERROR;
                        p->next = rem->next;
                        free(rem);

                        return l;
                }
        }

        return ERROR;
}
#endif

void linkedlist_print(struct linkedlist *l)
{
        if (l == NULL)
                printf("\n");
        else {
                printf("%ld ", l->value);
                linkedlist_print(l->next);
        }
}

int main(void)
{
        struct linkedlist *l;

        /* Test:
         * - Creeaza o lista noua.
         *
         * - Adauga pe rand elementele 1, 2, 3, 4.
         *
         * - Adauga elementul 5 pe pozitia 2.
         *
         * - Ia capul listei
         *
         * - Ia coada listei
         *
         * - Ia elementul de pe pozitia 2.
         *
         * - Sterge elementul de pe pozitia 2.
         *
         * - Sterge elementul de pe pozitia 0.
         */
        l = linkedlist_new();
        l = linkedlist_cons(1, linkedlist_cons(2, linkedlist_cons(3, l)));
        l = linkedlist_cons(4, l);
        printf("l = "); linkedlist_print(l);
        l = linkedlist_insert(5, 2, l);
        printf("after inserting at pos 2, l = "); linkedlist_print(l);
        printf("head(l) = %ld\n", linkedlist_head(l));
        l = linkedlist_tail(l);
        printf("l = tail(l) = "); linkedlist_print(l);
        /* printf("l[2] = %ld\n", linkedlist_get(2, l)); */
        l = linkedlist_remove(2, l);
        printf("removed l[2]; l = "); linkedlist_print(l);
        l = linkedlist_remove(0, l);
        printf("removed l[0]; l = "); linkedlist_print(l);
        free(l);

        /* Discutie: lista simplu inlantuita este "in mod natural" "mai
         * functionala" decat array list-ul, deoarece se bazeaza pe
         * manipularea de referinte, fara a modifica insa restul listei
         * (cum se intampla de exemplu in cazul stergerii).
         *
         * Ar fi util urmatorul exercitiu: implementarea unui array list
         * cu o interfata foarte similara cu cea a linked list-ului
         * (pastrand insa avantajele de complexitate date de array list)
         * si utilizarea ei intr-un mod functional, chiar daca
         * implementarea in sine e imperativa.
         */

        /* Bonus:
         *
         * - Concatenarea a doua liste
         */
        return 0;
}
