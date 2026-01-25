# TP – Module 3 DevSecOps : Sécuriser une image Docker (Trivy + bonnes pratiques)

Ce dépôt est **clé en main** pour le TP du **Module 3** :
- Scanner une image
- Corriger un Dockerfile non sécurisé
- Rescanner
- Publier (optionnel)
- Automatiser en CI/CD (GitHub Actions / GitLab CI)

> Pré-requis : Docker + Trivy
> - Docker : https://docs.docker.com/get-docker/
> - Trivy : https://aquasecurity.github.io/trivy/

---

## Structure

- `app/` : petite API HTTP Go (port 8080)
- `Dockerfile.insecure` : volontairement **insecure**
- `Dockerfile.secure` : version **corrigée** (multi-stage + non-root + image runtime minimale)
- `scripts/` : scripts de scan Trivy
- `.github/workflows/` : pipeline GitHub Actions (scan bloquant)
- `.gitlab-ci.yml` : pipeline GitLab CI (scan bloquant)

---

## Objectif pédagogique

1. Construire l'image à partir de `Dockerfile.insecure`
2. Lancer Trivy sur l'image et analyser le rapport
3. Appliquer des corrections (ou comparer avec `Dockerfile.secure`)
4. Reconstruire, rescanner, constater l'amélioration
5. (Bonus) Brancher le scan dans la CI/CD

---

## Étape 0 — Vérifications

```bash
docker --version
trivy --version
```

---

## Étape 1 — Build de l’image insecure

```bash
docker build -f Dockerfile.insecure -t module3/insecure:latest .
```

Lancer l’app (optionnel) :

```bash
docker run --rm -p 8080:8080 module3/insecure:latest
# puis : curl http://localhost:8080/health
```

---

## Étape 2 — Scan Trivy (image)

Scan standard (console) :

```bash
./scripts/trivy_image.sh module3/insecure:latest
```

Scan + export JSON :

```bash
./scripts/trivy_image_json.sh module3/insecure:latest
```

👉 Points à observer :
- vulnérabilités **CRITICAL / HIGH**
- packages concernés
- correctifs disponibles ou non

---

## Étape 3 — Corriger

Deux options :
- **Option A (pédagogique)** : corriger `Dockerfile.insecure` progressivement
- **Option B (référence)** : comparer avec `Dockerfile.secure`

Rebuild de l’image secure :

```bash
docker build -f Dockerfile.secure -t module3/secure:latest .
```

---

## Étape 4 — Rescan + comparaison

```bash
./scripts/trivy_image.sh module3/secure:latest
```

Comparer :
- nombre total de vulnérabilités
- surface d’attaque (taille image)
- présence d’un user non-root
- présence d’outils de build dans l’image runtime

---

## Étape 5 — (Optionnel) Scan filesystem / repo

```bash
./scripts/trivy_fs.sh .
```

---

## Seuil de blocage recommandé

Pour le TP, on conseille :
- échec pipeline sur **CRITICAL** (ou CRITICAL+HIGH selon le niveau)
- exceptions : documentées (pas “on ignore”)

---

## CI/CD

### GitHub Actions
Le workflow :
- build l’image
- scanne avec Trivy
- échoue si sévérité >= HIGH (paramétrable)

### GitLab CI
Pipeline équivalent dans `.gitlab-ci.yml`.

---

## Notes formateur

- Le Dockerfile insecure illustre :
  - image de base large/ancienne
  - build tools dans l’image finale
  - exécution en root
  - “faux” secret embarqué (fichier `.env.example`)
- Le secure illustre :
  - multi-stage
  - runtime minimal
  - user non-root
  - réduction surface d’attaque

Bon TP.
