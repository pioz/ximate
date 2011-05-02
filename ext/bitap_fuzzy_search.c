#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ruby.h>

#include <stdio.h>

char *
downcase2 (const char *s)
{
  int i, size = strlen (s);
  if (size > 31) size = 31;
  char *down_s = malloc (size + 1);
  for (i = 0; i < size; i++)
    down_s[i] = tolower (s[i]);
  down_s[size] = '\0';
  return down_s;
}


static VALUE
bitap_fuzzy_search (VALUE self, VALUE text, VALUE pattern, VALUE errors_percent)
{
  char *p = downcase2 (StringValuePtr (pattern));
  if (p[0] == '\0') return Qnil;
  char *t = downcase2 (StringValuePtr (text));
  int n = strlen (t);
  int m = strlen (p);
  if (abs (n - m) > 2) return Qnil;
  const char *result = NULL;
  unsigned long *R;
  unsigned long bitmasks[CHAR_MAX + 1];
  int i, d;

  int errors = (FIX2INT (errors_percent) * m) / 100;
  if (errors == 0) errors = 1;

  /* Initialize the bit array R */
  R = malloc ((errors + 1) * sizeof (*R));
  for (i = 0; i <= errors; ++i)
    R[i] = ~1;

  /* Initialize the pattern bitmasks */
  for (i = 0; i <= CHAR_MAX; ++i)
    bitmasks[i] = ~0;
  for (i = 0; i < m; ++i)
    bitmasks[p[i]] &= ~(1UL << i);

  for (i = 0; t[i] != '\0'; ++i)
    {
      /* Update the bit arrays */
      unsigned long old_Rd1 = R[0];

      R[0] |= bitmasks[t[i]];
      R[0] <<= 1;

      for (d = 1; d <= errors; ++d)
        {
          unsigned long tmp = R[d];
          /* Substitution is all we care about */
          R[d] = (old_Rd1 & (R[d] | bitmasks[t[i]])) << 1;
          old_Rd1 = tmp;
        }

    if (0 == (R[errors] & (1UL << m)) && (i - m + 1) == 0)
      {
        result = (t + i - m) + 1;
        break;
      }
    }

  free (R);
  free (p);
  free (t);

  if (result)
    return rb_str_new2 (result);
  return Qnil;
}


void
Init_bitap_fuzzy_search ()
{
  /* Define Bitap fuzzy search class */
  VALUE fuzzy = rb_define_class ("Fuzzy", rb_cObject);
  rb_define_singleton_method (fuzzy, "search", bitap_fuzzy_search, 3);
}