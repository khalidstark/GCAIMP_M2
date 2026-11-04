# GCAIMP · Milestone 2

GIU Curriculum and Academic Innovation Management Platform: SQL Server database, procedures and functions.

| File | What it is | Who edits it |
|---|---|---|
| `Tables.sql` | Creates the `GCAIMP` database and all tables | Agreed by the team |
| `Insertions.sql` | Sample data | Agreed by the team |
| `procedures/<Name>.sql` | Your procedures and functions (you create it on your branch) | **Only you** |
| `executions/<Name>.sql` | Your `EXEC` / `SELECT` test calls (you create it on your branch) | **Only you** |
| `Procedures.sql` | All procedures glued together | **Nobody (CI generates it)** |
| `Executions.sql` | All executions glued together | **Nobody (CI generates it)** |
| `Procedures.pdf` | User stories split between the team | Nobody |

## How we work on procedures

Each team member has their own branch and their own file. Nobody writes directly in `Procedures.sql` on `main`. When you merge your branch into `main`, CI/CD glues everyone's work into the main `Procedures.sql`.

| Member | Branch | Procedures file | Executions file |
|---|---|---|---|
| Khalid | `khalid` | `procedures/Khalid.sql` | `executions/Khalid.sql` |
| Lamar | `lamar` | `procedures/Lamar.sql` | `executions/Lamar.sql` |
| Jomana | `jomana` | `procedures/Jomana.sql` | `executions/Jomana.sql` |
| Abdallah | `abdallah` | `procedures/Abdallah.sql` | `executions/Abdallah.sql` |
| Rawan | `rawan` | `procedures/Rawan.sql` | `executions/Rawan.sql` |

### Steps

1. **Get the repo and switch to your branch** (first time only):
   ```bash
   git clone https://github.com/khalidstark/GCAIMP_M2.git
   cd GCAIMP_M2
   git checkout khalid        # use your own branch name
   ```
2. **Get the latest `main` before you start working:**
   ```bash
   git pull origin main
   ```
3. **Create your files** (first time only) and write your procedures in `procedures/<YourName>.sql` and your test calls in `executions/<YourName>.sql`.
   - Use the exact file name from the table above (e.g. `procedures/Lamar.sql`, capital first letter).
   - Put `GO` between each `CREATE PROCEDURE` / `CREATE FUNCTION`.
   - You don't need `USE GCAIMP;` at the top. CI adds it.
   - Don't touch other people's files, `Procedures.sql` or `Executions.sql`.
4. **Test locally** in SQL Server in this order: `Tables.sql` → `Insertions.sql` → your procedures file → your executions file.
5. **Commit and push to your branch:**
   ```bash
   git add procedures/<YourName>.sql executions/<YourName>.sql
   git commit -m "Add <procedure names>"
   git push origin <your-branch>
   ```
6. **Open a Pull Request** from your branch into `main` on GitHub, then merge it.

### What the CI/CD does after a merge

Every push or merge to `main` runs `.github/workflows/glue.yml`. It:

1. Glues every `procedures/*.sql` file into `Procedures.sql` (order: Khalid, Lamar, Jomana, Abdallah, Rawan, then any other file), and the same for `executions/*.sql` → `Executions.sql`.
2. Starts a fresh SQL Server 2022 container and runs `Tables.sql` → `Insertions.sql` → `Procedures.sql` → `Executions.sql`.
3. If everything runs without errors, it commits the updated `Procedures.sql` and `Executions.sql` back to `main`.

If the run fails (red ❌ in the **Actions** tab), `Procedures.sql` is **not** updated. Open the failed run, find the file and line that errored, fix it on your branch and merge again.

### Rules

- One person per file. Since you only edit your own file, merges never conflict.
- Never edit `Procedures.sql` or `Executions.sql` by hand. CI overwrites them.
- Run `git pull origin main` before you start working, so your branch stays up to date.
- If you need to change `Tables.sql` or `Insertions.sql`, tell the team first, because it affects everyone's procedures.
