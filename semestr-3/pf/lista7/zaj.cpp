#include <bits/stdc++.h>
using namespace std;

const int ALPHABET_SIZE = 26;

struct node
{
  node *children[ALPHABET_SIZE];
  int cnt;
  bool is_end;

  node()
  {
    for (int i = 0; i < ALPHABET_SIZE; i++)
      children[i] = nullptr;
    is_end = false;
    cnt = 0;
  }
};

struct TRIE
{
  node *root;

  TRIE()
  {
    root = new node;
  }

  // dodaje słowo do słownika
  void add_word(string word)
  {
    node *crawl = root;
    for (auto c : word)
    {
      int letter = c - 'a';
      if (crawl->children[letter] == nullptr)
      {
        crawl->children[letter] = new node;
      }
      crawl = crawl->children[letter];
    }
    crawl->is_end = true;
  }

  // sprawdź czy słowo jest w słowniku
  bool find(string word)
  {
    node *crawl = root;
    for (auto c : word)
    {
      int letter = c - 'a';
      if (crawl->children[letter] == nullptr)
        return false;
      crawl = crawl->children[letter];
    }
    return crawl->is_end;
  }

  // usuń słowo ze słownika
  void erase(string word) {}
};

int main()
{
  TRIE dictionary;
  int q;
  cin >> q;
  while (q--)
  {
    char c;
    string s;
    cin >> c >> s;
    if (c == 'A')
      dictionary.add_word(s);
    else
      cout << (dictionary.find(s) ? "TAK" : "NIE")
           << "\n";
  }
}