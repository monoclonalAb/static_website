---
title: Uncompetitively Competing in Competitive Programming
date: 2025-02-26
---

# intro<span>:</span>

The second month may be coming to a close, and a certain individual has **definitely not** been procrastinating his second blog post of the year.
During this time, I decided to participate in a *competitive programming competition* sponsored by a company beginning with I.
Unfortunately, however, I believe that I did not have the best showing at this event so *naturally*, 
I decided it would only be *right* to do a write-up for every question so *mishaps* like this will never happen again.

## Problem A<span>:</span> Back to the Futures

Sabine wants to trade some stocks and make as much money as possible. 
She has `M` dollars to start with and knows the future prices of `S` different stocks for the next `D` days (thanks to a time machine).

Sabine wants to keep her trading strategy simple. Each day, Sabine will choose **exactly one** of the following
three options:

:::sidebar
- **Buy**: Sabine chooses one type of stock, and buys any number of that stock she would like (at that day’s price). She can only buy a whole number of stocks, so she may have some money left over. **Sabine can only choose this option if she currently has no stock.**
- **Sell**: Sabine sells all the stocks she has.
- **Nothing**: Sabine does nothing.
:::

To avoid suspicion, she will choose the Buy option **at most `T` times**, where `T` is one or two. What is the
maximum amount of money Sabine can end with?

### Input<span>:</span>

The first line of input contains four integers `T (1 ≤ T ≤ 2)`, which is the maximum number of Buys Sabine can
do, `S (1 ≤ S ≤ 10)`, which is the number of different types of stocks, `D (2 ≤ D ≤ 200 000)`, which is the number
of days, and `M (1 ≤ M ≤ 1 000)`, which is the amount of money Sabine starts with.

The next `D` lines describe each day’s stock prices. Each line contains `S` integers each in the inclusive range
from `1` to *1 000*. The *j*th integer on the *i*th line is the price of stock *j* on day *i*.

### Special constraints for subtasks<span>:</span>

*Subtask 1*: `D ≤ 20` and `T = 1` (4 points) \
*Subtask 2*: `D ≤ 20` (5 points) \
*Subtask 3*: No special constraints (11 points)

### Output<span>:</span>

Display a single number, the maximum amount of money Sabine can have after `D` days.

### Write-Up<span>:</span>

This was the second question solved by most participants.
If you know your *dynamic programming*, you can easily tell that it is the intended solution.

This is because the output wants us to return the **maximum** amount of money to end with on day `D` (the final day) after `n` transactions,
and that can be one of two options:

:::sidebar
- the **maximum** amount of money to end with on day `D` after `n-1` transactions,
- the **maximum** amount of money to end with on day `D` after `n` transactions, if we start on day `d` (`2 <= d < D-1`) with the **maximum** amount of money to end with on day `d` after `n-1` transactions
    - however, for this case, we will have to iterate through all examples with **unique** amounts of starting money (as some positions may have missed the opportunity to make the optimal trades)
:::

Now, the main parts of my algorithm is the `dp` array and the `return_maximum_profit` function:

:::sidebar
- the `dp[i][j]` is a 2-dimensional array that keeps track of the maximum amount of money to end with on day `j` made in `i` or less trades
    - that was the goal, but since the question only need to find the maximum amount of money from `1` or `2` trades, `dp[2][j]` is actually quite hard-coded
- the `return_maximum_profit` function's job is to just return the **maximum** profit possible depending on the *day*, `d`, and the *number of trades we can make* , `t`
    - basically, it finds the **maximum** starting money for day `d-1` using only max `t-1` trades, which will be located at `dp[t-1][d-1]`, and then iterates through the remainder of days `d -> D`, calculating the new **maximum** profit if we have the option of buying **low** and selling **high**
    - again, since this question does not end up functioning for cases greater than `2` trades, I decided to hard-code the case for `2` trades
:::

Therefore, for the 2 cases:

:::sidebar
- if `T = 1`, we can just run `return_maximum_profit` 
- if `T = 2`, we need to iterate between all starting days `d`, for `2 <= d <= D-1`
    - the inequality `2 <= d <= D-1` exists, since it is impossible for a transaction to have occurred previously if we were to start on days `0` and `1` and it is impossible for a transaction to occur in the future if were to start on days `D`
    - then, checking that our **maximum** starting money is *unique*, we can consequently run `return_maximum_profit` starting from day `d` with a maximum of `t` trades, starting with `dp[t-1][d-1]` amounts of cash
:::

### Code<span>:</span>

``` {.cpp}
#include <bits/stdc++.h>
using namespace std;

int return_maximum_profit (int M, int t, int sd, vector<int> &mn, vector<vector<int>> &price, vector<vector<int>> &dp) {
  for (int s = 0; s < mn.size(); ++s) {
    mn[s] = price[sd][s];
  }

  for (int d = sd+1; d < dp[0].size(); ++d) {
    dp[t][d] = dp[t][d-1];
    for (int s = 0; s < mn.size(); ++s) {
      mn[s] = min(mn[s], price[d-1][s]);
      if (price[d][s] > mn[s]) {
        int shares = M/mn[s];
        dp[t][d] = max(dp[t][d], M + shares * (price[d][s] - mn[s]));
      }
    }
  }

  return dp[t][dp[0].size()-1];
}

int main() {
  // T = max number of buys, (1 <= T <= 2)
  // S = number of stocks, (1 <= S <= 10)
  // D = number of days, (2 <= D <= 200,000)
  // M = amount of money Sabine starts with (1 <= M <= 1000)
  int T, S, D, M;
  cin >> T >> S >> D >> M;

  vector<vector<int>> price(D, vector<int>(S));

  for (int d = 0; d < D; ++d) {
    for (int s = 0; s < S; ++s) {
      cin >> price[d][s];
    }
  }

  vector<int> mn (S);
  vector<vector<int>> dp (3, vector<int>(D));

  for (int i = 0; i < dp.size(); ++i) {
    dp[i][0] = M;
  }

  int ans = return_maximum_profit(M, 1, 0, mn, price, dp);

  if (T == 1) {
    cout << ans << endl;
    return 0;
  } else {
    for (int d = 2; d < D-1; ++d) {
      if (dp[1][d-1] != dp[1][d-2]) {
        ans = max(ans, return_maximum_profit(dp[1][d-1], 2, d, mn, price, dp));
      }
    }
    cout << ans << endl;
    return 0;
  }
}
```

## Problem B<span>:</span> Numbers Puzzle

You arrive late to class one day, expecting to be scolded. 
Instead, you find everyone staring at the whiteboard: `3 × n` numbers have been scribbled onto it. 
The lecturer turns to you.

“You are late. I will forgive you if you solve this puzzle. Group these numbers into `n` sets of three. 
Each set must either be three identical values (such as `[5, 5, 5]`, a student helpfully chimes in), 
or three consecutive values (such as `[6, 7, 8]`).”

You nod your head sagely. You cannot solve this problem, but perhaps your laptop can.

### Input<span>:</span>

The first line of input contains the integer `n (1 ≤ n ≤ 100 000)`.

The next line contains `3 × n` positive integers between `1` and `100 000` inclusive, describing the numbers on the
whiteboard.

### Special constraints for subtasks<span>:</span>

*Subtask 1*: `n = 1` (4 points) \
*Subtask 2*: `n ≤ 4` (6 points) \
*Subtask 3*: No special constraints (10 points)

### Output<span>:</span>

If it is impossible to group the numbers into `n` sets of three, display `Impossible`. Otherwise, display `Forgiven` followed by `n` lines, each representing a set.

The sets (and the numbers within a set) may be displayed in any order. If there are multiple solutions, any will be accepted.

### Write-Up<span>:</span>

This question was the first one getting solved by everyone in the competition - since the solution is quite easy to spot.

First, we know that there are 2 groups that have been defined:

::: sidebar
- groups that contain 3 consecutive numbers
- groups that contain 3 of the same numbers
:::

Through this, realise that forming groups of 3 consecutive numbers is quite a restrictive requirement, 
as trying to form `n` groups of the same 3 consecutive numbers (let these be `x`, `x+1` and `x+2`) means we need at least `n` copies of each number.

Consequently, realise that if we can form `n > 3` groups of 3 consecutive numbers (`x`, `x+1` and `x+2`),
it implies that we can split it up into `3` seperate `n//3` (floor of `n/3`) groups of `x`, `x+1` and `x+2`
and `n%3` (remainder of `n/3`) groups of the consecutive numbers `x`, `x+1` and `x+2`.

This implies that it is possible for us to take a greedy approach, by forming as many groups of the same 3 numbers,
before considering forming any groups with 3 consecutive numbers.

Therefore, to solve this question, we can place all the `3 * n` numbers into a `map` with the key being the number, and the value being the count of that number.
Then, we should iterate through the `[key, value]` pairs in `map` in order from smallest to highest:

:::sidebar
- for every `key`, check what `value % 3` is:
    - if it is `== 0`, iterate to the next `key`
    - if it is `> 0`, subtract `value % 3` from `key+1` and `key+2`
    - if it is `< 0`, then we know that it is impossible to group, and can display *Impossible*
:::

Then, if we are able to iterate through all the `keys` without breaking,
then we can just re-iterate through the `[key, value]` pairs in `map`:

:::sidebar
- for every `key`,
    - paste `key key key` for the floor of `value / 3` times
    - paste `key key+1 key+2` for the remainder of `value / 3` times (we can do this since we got rid of `value % 3` in both `key+1` and `key+2`)
:::

### Code<span>:</span>

``` {.cpp}
#include <bits/stdc++.h>
using namespace std;

int main() {
  int n; cin >> n;
  map<int, int> mp;
  for (int i = 0; i < 3*n; ++i) {
    int temp; cin >> temp;
    ++mp[temp];
  }
  for (auto& [key, value] : mp) {
    if (value < 0) {
      cout << "Impossible" << endl;
      return 0;
    }
    int remainder = value%3;
    if (remainder != 0) {
      mp[key+1] -= remainder;
      mp[key+2] -= remainder;
    }
  }
  cout << "Forgiven\n";
  for (auto& [key, value] : mp) {
    int quotient = value/3;
    int remainder = value%3;
    for (int i = 0; i < quotient; ++i) {
      cout << key << " " << key << " " << key << "\n";
    }
    for (int i = 0; i < remainder; ++i) {
      cout << key << " " << key+1 << " " << key+2 << "\n";
    }
  }
  return 0;
}
```

## Problem C<span>:</span> Pair of Watchtowers

You’ve just been asked to plan the construction of two watchtowers in your local nature reserve. There is a
straight trail which runs through the reserve from west to east.

Along the trail are `n` potential build sites. A team of surveyors has collected three critical pieces of information
about each site: the exact location of the site on the trail, the number of trees that would need to be cut down to
build the tower, and the “buffer radius” for the site.

The two sites you choose must be outside of each other’s buffer radii. Keeping this constraint in mind, what is
the fewest trees that need to be cut down?

### Input <span>:</span>

The first line of input contains the integer `n (2 ≤ n ≤ 200 000)`, which is the number of sites.

The next `n` lines describe the sites. Each of these lines contains three integers `x (0 ≤ x ≤ 109)`, 
which is the distance the site is from the east end of the trail in metres, `t (0 ≤ t ≤ 108)`, 
which is the number of trees that would need to be cut down, and `r (1 ≤ r ≤ 109)`, 
which is the buffer radius.
This means the other site you choose must be **strictly more** than `r` metres west or east of this site.

The sites are listed in increasing order of `x`.
No two sites will have the same value of `x`.

### Special constraints for subtasks<span>:</span>

*Subtask 1*: The radii of all towers are the same and `n ≤ 1000` (4 points) /
*Subtask 2*: The radii of all towers are the same (8 points) /
*Subtask 3*: No special constraints (13 points) 

### Output<span>:</span>

If it is not possible to find two sites satisfying the condition, display `Delay`. 
Otherwise, display `Proceed`, followed by a single integer `M`, which is the fewest trees that need to be cut down.

### Write-Up<span>:</span>

Here is the problem with **arrays** and **prefix arrays**:

:::sidebar
- for **arrays**:
    - `O(1)` time for *point updates*
    - `O(n)` time for *prefix sum queries*
- for **prefix arrays**:
    - `O(n)` time for *point updates*
    - `O(1)` time for *prefix sum queries*
:::

Now, we can introduce a *new-and-very-useful* data structure **fenwick trees** (or **bit indexed tree**) with:

::: sidebar
- `O(log n)` time for *point updates*
- `O(log n)` time for *prefix sum queries*
:::

This is useful because:

:::sidebar
- when iterating through potential **right-hand side** build-sites, we can *point update* a build-site and its corresponding *tree count* to the **fenwick tree** once we know that it is **valid** 
    - we can do this by sorting (from *lowest* to *highest*) the minimum index a corresponding build-site has to have to be a *valid* **right-hand side** build-site
- we can then run a *prefix sum query* to query for the **minimum** *tree count* of all the potential **left-hand side** build-sites
    - we can do this by calculating the maximum index, `max_index`, a corresponding **left-hand side** build-site can posess, and then querying the **minimum** *tree count* of all sites between index `0` and `max_index-1`
:::

### Code<span>:</span>

``` {.cpp}
#include <bits/stdc++.h>
using namespace std;

struct site {
  int x;
  int t;
  int r;
};

struct fenwick {
  int n;
  vector<int> tree;
  fenwick (int n) : n(n+1), tree(vector<int>(n+1, INT32_MAX)) {}

  void add(int i, int val) {
    ++i;
    for (; i < n; i += i & -i) {
      tree[i] = min(tree[i], val);
    }
  }

  int query(int i) {
    ++i;
    int ans = INT32_MAX;
    for (; i > 0; i -= i & -i) {
      ans = min(ans, tree[i]);
    }
    return ans;
  }
};

int main() {
  int n; cin >> n;

  vector<site> sites(n);
  vector<int> x_pos(n);
  for (int i = 0; i < n; ++i) {
    cin >> sites[i].x >> sites[i].t >> sites[i].r;
    x_pos[i] = sites[i].x;
  }

  vector<pair<int, int>> valid_indices(n);
  for (int i = 0; i < n; ++i) {
    int valid_index = lower_bound(x_pos.begin(), x_pos.end(), sites[i].x + sites[i].r + 1) - x_pos.begin();
    valid_indices[i] = {valid_index, i};
  }
  sort(valid_indices.begin(), valid_indices.end());

  fenwick fenwick_tree(n);

  int ans = INT32_MAX;
  int pointer = 0;
  for (int i = 0; i < n; ++i) {
    // only add the valid sites to the fenwick tree
    while (pointer < n && valid_indices[pointer].first == i) {
      fenwick_tree.add(valid_indices[pointer].second, sites[valid_indices[pointer].second].t);
      ++pointer;
    }

    //
    int max_index = lower_bound(x_pos.begin(), x_pos.end(), sites[i].x-sites[i].r) - x_pos.begin();
    if (max_index > 0) {
      int best = fenwick_tree.query(max_index-1);
      if (best != INT32_MAX)
        ans = min(ans, best+sites[i].t);
    }
  }

  if (ans == INT32_MAX) {
    cout << "Delay" << endl;
  } else {
    cout << "Proceed" << endl;
    cout << ans << endl;
  }

  return 0;
}
```

## Problem D<span>:</span> Lettuce and Numbers

Welcome to the newest **IMC** (International Media Corporation) game show, “Lettuce and Numbers”. The
game involves strings not of letters, but of lettuces! There are two types of lettuces: ‘`a`’ and ‘`b`’.

The host explains that Lettuce and Numbers comprises two separate phases.

::: sidebar
- **Phase 1**. You choose a string of length exactly `N`. However there are `R` banned prefix strings. The chosen string cannot begin with any of the banned prefixes.
- **Phase 2**. You perform a sequence of *merge* operations until just a single lettuce remains. A merge involves picking two adjacent lettuces and merging them into one. If the left lettuce is type `x` and the right lettuce is type `y`, then the resulting lettuce will be of type `L_(x,y)` and you will earn `P_(x,y)` points.
:::

At the end, you get to eat the last lettuce while the host sums up the points earned across your merges. You
want to find out the maximum number of points you can achieve. And to really impress everyone, you also want
to find out how many different ways there are to achieve the maximum number of points.

Two ways are different if the constructed string is different or the sequence of merges is different.

### Input<span>:</span>

The first line of input contains two integers `N (1 ≤ N ≤ 300)` and `R (0 ≤ R ≤ 100)`.

The next `R` lines list the banned prefixes. The length of each prefix is in the inclusive range from `1` to `N`. The
sum of lengths over all banned prefixes does not exceed `300`.

The next two lines each contain a two-character string, describing `L`. The characters on the first line are `L_(a,a)`
and `L_(a,b)`. The characters on the second line are `L_(b,a)` and `L_(b,b)`

The next two lines each contain two integers, describing `P`. The integers on the first line are `P_(a,a)` and `P_(a,b)`.

The integers on the second line are `P_(b,a)` and `P_(b,b)`. Each integer in `P` is in the inclusive range from `0` to `1000`.

### Special constraints for subtasks<span>:</span>

*Subtask 1*: `R = 0` and `N ≤ 6` (4 points) \
*Subtask 2*: `R = 0` (7 points) \
*Subtask 3*: No special constraints (24 points)

### Output<span>:</span>

Display the highest possible number of points achievable and the number of ways to achieve it. 
Since the number of ways may be large, display it modulo `1 000 000 007`.
If there are no ways to complete the game, display `0 0`.

### Write-Up<span>:</span>

### Code<span>:</span>

``` {.cpp}
#include <bits/stdc++.h>
using namespace std;

int merge_result[2][2];
int points_earned[2][2];

struct lettuce_key {
  int letter;
  string prefix;

  bool operator==(const lettuce_key &other) const {
    return letter == other.letter && prefix == other.prefix;
  }
};

struct lettuce_hash {
    std::size_t operator()(const lettuce_key &k) const {
        size_t res = 17;
        res = res * 31 + std::hash<int>()(k.letter);
        res = res * 31 + std::hash<string>()(k.prefix);
        return res;
    }
};

struct lettuce_value {
  int score;
  int ways;
};

int max_prefix_length;

vector<string> banned;

bool is_prefix_valid(string &s) {
  for (string & ban : banned) {
    if (s.size() >= ban.size()) {
      if (s.substr(0, ban.size()) == ban) {
        return false;
      }
    }
  }
  return true;
};

string combine_string (string &s1, string &s2) {
  if (s1.size() >= max_prefix_length) {
    return s1;    
  }
  int additional_length = max_prefix_length - s1.size();
  string ans = s1;
  ans += s2.substr(0, min(int(s2.size()), additional_length));
  return ans;
}

int main() {
  int N, R;
  cin >> N >> R;

  for (int i = 0; i < R; ++i) {
    string temp; cin >> temp;
    banned.push_back(temp);
    max_prefix_length = max(max_prefix_length, int(temp.size()));
  }  
  if (max_prefix_length == 0) max_prefix_length = 1;

  string line;
  cin >> line;
  char L_aa = line[0], L_ab = line[1];
  cin >> line;
  char L_ba = line[0], L_bb = line[1];

  merge_result[0][0] = (L_aa == 'a' ? 0 : 1);
  merge_result[0][1] = (L_ab == 'a' ? 0 : 1);
  merge_result[1][0] = (L_ba == 'a' ? 0 : 1);
  merge_result[1][1] = (L_bb == 'a' ? 0 : 1);

  for (int i = 0; i < 4; ++i) {
    int r = i/2;
    int c = i%2;
    cin >> points_earned[r][c];
  }

  vector<vector<unordered_map<lettuce_key, lettuce_value, lettuce_hash>>> dp(N+1, vector<unordered_map<lettuce_key, lettuce_value, lettuce_hash>>(N+1));

  // initialize intervals of length 1
  for (int i = 1; i <= N; ++i) {
    lettuce_key a;
    a.letter = 0;
    a.prefix = "a";
    if (i!=1 || is_prefix_valid(a.prefix)) {
      dp[i][i][a] = {0, 1};
    }
    lettuce_key b;
    b.letter = 1;
    b.prefix = "b";
    if (i!=1 || is_prefix_valid(b.prefix)) {
      dp[i][i][b] = {0, 1};
    }
  }

  // initialize intervals of length > 1
  for (int length = 2; length <= N; ++length) {
    for (int l = 1; l <= N-length+1; ++l) {
      int r = l + length - 1;

      dp[l][r].clear();

      for (int s = l; s < r; ++s) {
        for (auto &LHS : dp[l][s]) {
          int character_LHS = LHS.first.letter;
          string prefix_LHS = LHS.first.prefix;
          int score_LHS = LHS.second.score;
          int ways_LHS = LHS.second.ways;
          for (auto &RHS : dp[s+1][r]) {
            int character_RHS = RHS.first.letter;
            string prefix_RHS = RHS.first.prefix;
            int score_RHS = RHS.second.score;
            int ways_RHS = RHS.second.ways;

            int new_letter = merge_result[character_LHS][character_RHS];
            int new_score = score_LHS + score_RHS + points_earned[character_LHS][character_RHS];

            string new_prefix = combine_string(prefix_LHS, prefix_RHS);

            if(l == 1 && !is_prefix_valid(new_prefix))
                continue; 
            
            lettuce_key new_key;
            new_key.letter = new_letter;
            new_key.prefix = new_prefix;

            if(dp[l][r].find(new_key) == dp[l][r].end()){
                dp[l][r][new_key] = {new_score, (int)((1LL * ways_LHS * ways_RHS) % int(1e9+7))};
            } else {
                lettuce_value &cur = dp[l][r][new_key];
                if(new_score > cur.score){
                    cur.score = new_score;
                    cur.ways = (int)((1LL * ways_LHS * ways_RHS) % int(1e9+7));
                } else if(new_score == cur.score){
                    cur.ways = (cur.ways + (int)((1LL * ways_LHS * ways_RHS) % int(1e9+7))) % int(1e9+7);
                }
            }
          }
        }
      }
    }
  }
  int bestScore = -1;
  int waysAns = 0;

  for(auto &entry : dp[1][N]){
    int sc = entry.second.score;
    if(sc > bestScore){
      bestScore = sc;
      waysAns = entry.second.ways;
    } else if(sc == bestScore){
      waysAns = (waysAns + entry.second.ways) % int(1e9+7);
    }
  }

  if(bestScore == -1) {
    cout << "0 0\n";
  } else {
    cout << bestScore << " " << waysAns % int(1e9+7) << "\n";
  }

  return 0;
}
```
