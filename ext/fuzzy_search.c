#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ruby.h>

#include <stdio.h>

char *
downcase (const char *s)
{
  int i, size = strlen (s);
  if (size > 31) size = 31;
  char *down_s = malloc (size + 1);
  for (i = 0; i < size; i++)
    down_s[i] = tolower (s[i]);
  down_s[size] = '\0';
  return down_s;
}

int
minimum (int x, int y, int z)
{
  int min = x;
  if (y < min) min = y;
  if (z < min) min = z;
  return min;
}

int
maximun (int x, int y)
{
  return (x < y) ? y : x;
}

int
levenshtein_distance (const char *s, const char *t)
{
  /* Declarations */
  int n = strlen (s);
  int m = strlen (t);
  int i, j, k, distance;

  /* Init matrix */
  int *prev = malloc ((n + 1) * sizeof (int));
  int *curr = malloc ((n + 1) * sizeof (int));
  int *tmp = NULL;
  for (i = 0; i <= n; ++i) prev[i] = i;

  /* Start */
  for (i = 1; i <= m; i++)
    {
      curr[0] = i;
      for (j = 1; j <= n; j++)
        {
          if (s[i-1] != t[j-1])
            {
              k = minimum (curr[j-1], prev[j-1], prev[j]);
              curr[j] = k + 1;
            }
          else
            curr[j] = prev[j-1];
        }
      tmp = prev;
      prev = curr;
      curr = tmp;
      memset ((void*)curr, 0, sizeof (int) * (n + 1));
    }
  distance = prev[n];

  free (prev);
  free (curr);

  return distance;
}

static VALUE
fuzzy_equal (VALUE self, VALUE text, VALUE pattern, VALUE errors_percent)
{
  const char *t = StringValuePtr (text);
  const char *p = StringValuePtr (pattern);
  int errors = (errors_percent * maximun (strlen (t), strlen (p))) / 100;
  int distance = levenshtein_distance (t, p);
  // printf ("Allowed errors: %d - Levenshtein's distance: %d\n", errors, distance);
  if (distance <= errors)
    return INT2NUM (errors - distance);
  return Qfalse;
}


void
Init_fuzzy_search ()
{
  /* Define Bitap fuzzy search class */
  VALUE fuzzy = rb_define_class ("Fuzzy", rb_cObject);
  rb_define_singleton_method (fuzzy, "equal", fuzzy_equal, 3);
}