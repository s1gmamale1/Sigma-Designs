# Copy and truth

Every line on an Akademiya page is a claim a school director may hold us to.
Write for them, in their words, and only about what is Built.

## Voice

- **Reader:** the school's director or owner (private schools first). Not the
  teacher, not the student, not an investor.
- **Pain lines are scenes, not categories.** "Ask how 7-B is doing. You'll get
  an opinion, not a number." beats "Lack of analytics".
- **Answers recall the pain** in a short red line above the title ("No waiting
  for the quarter", "Instead of evening checking"), then a plain title and a
  one-paragraph body of what the product does.
- Plain verbs, sentence case, no filler, no superlatives the product can't
  back ("the most powerful" was cut from the old line for that reason).
- One call to action everywhere: **Book a demo** · **Demoga yozilish** ·
  **Записаться на демо**.

## The signature lines (en; uz/ru live in the content files)

| Slot | Line |
|---|---|
| Hero product line | Bring a powerful LMS with advanced AI to your school |
| Hero red line | All your school operations under one hood. |
| Pains title / sub | Sound familiar? / A normal week at most schools. |
| Turn | Let's fix this. / Introducing Akademiya AI for Schools! |
| Pilot | Try it in one grade first. / A free 6-week pilot. Our team imports your classes; the success measures and a decision date are agreed up front. / After that, $20 per student per month. |

The seven hooks, in story order (each answered further down the page):
1. Ask how 7-B is doing. You'll get an opinion, not a number.
2. Your school runs on paper, Telegram chats and Excel.
3. Your teachers are still checking notebooks at 10 pm.
4. Every lesson is built from scratch. Every night.
5. At 9 pm a student is stuck, and there's no one to ask.
6. Parents only call when something's already wrong.
7. You find out when the quarter is over. ← the punchline, right before the turn

## Owner decisions for the school product (fixed; do not reopen)

These bind the school product only. Another product line gets its own offer
from the owner; until then it states no price, pilot or duration.

| Topic | Rule |
|---|---|
| Price | "$20 per student per month". No so'm/UZS amounts, no −30%, no "founding schools" or "first ten schools" deals |
| Pilot | Free, 6 weeks, one grade; our team imports the data; success measures and the decision date agreed up front |
| Data law / hosting | No residency or hosting claims ("data stays with the school" is banned) |
| Demos | In-house fixtures only; never a live tenant, never a login to a real environment |
| Analytics | Hooks only; nothing is tracked yet, so nothing is promised |
| Sample-data labels | Captures ship without a per-image "Sample data" chip (approved exception, DESIGN.md DEMO-01); the interactive demo page keeps its one-line "names and numbers are made up" notice |

## Never claim (not built)

SMS · push notifications · dark mode · live quizzes · a shop · licence renewal ·
Telegram as a product feature (bot, notifications, mini app — Telegram is only
a contact channel) · a staff/teacher/director mobile app · payments in the app ·
self-serve sign-up · parent self-activation codes · the old product name.
Not even as "coming soon".

## Never claim (contradicted by the product)

- "The director adds teachers/students/parents" — our team loads the school.
- The recall check proves topic knowledge — it asks about the student's own
  answers, only after a strong run.
- "Every AI message is checked" — only the tutor's messages are claimed.
- Timetable automation of any kind.

The Frontend repo enforces both lists as regexes over every page × language,
including `<head>` meta (`src/pages/landing/truthPatterns.ts`); each guard has
known-bad samples so a passing run proves something. Add a guard when you add
a new class of claim.

## Names and people

- Only the fictional cast (Sardor Aliyev, Dilnoza Aliyeva, Bahodir Sodiqov),
  generated demo-school names, or test-fixture names. Never a hand-made QA
  account, never a name from a real tenant or production.
- No photo of a real person, and no screen showing a real person's name,
  without consent. No stock or AI photos posed as real schools.

## Numbers

- No statistic without a source the owner signs off. Numbers inside a product
  capture come from fixtures; they illustrate the screen, they are not results.
- Never a placeholder for future proof ("[PILOT DATA]", "XX% better").

## Languages

- Three locales in one typed content file per page (`content/*.ts`): uz first,
  then ru, en; the same keys and counts in each.
- Uzbek uses U+2018 for o‘ / g‘ (never a straight quote); Russian guards
  catch inflections ("десять/десяти").
- Machine-made uz/ru must get a native read before merge; say so in the PR.
- Prefer words over digits where a numeral would take an awkward suffix in
  Uzbek ("kechki soat o‘nda").
