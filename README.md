# dotfiles — structure stow

## Arborescence

```
~/dotfiles/
├── hypr/.config/hypr/          → symlinké vers ~/.config/hypr
├── waybar/.config/waybar/      → symlinké vers ~/.config/waybar
├── rofi/.config/rofi/          → symlinké vers ~/.config/rofi
├── mako/.config/mako/          → symlinké vers ~/.config/mako
└── alacritty/.config/alacritty/→ symlinké vers ~/.config/alacritty
```

Chaque dossier top-level = un "package" stow. La structure interne reproduit
exactement ce qui doit apparaître sous `~`.

## Setup initial

```bash
sudo pacman -S stow git
mkdir -p ~/dotfiles && cd ~/dotfiles
git init
# copie/déplace ta config actuelle dans la bonne arborescence ci-dessus
```

## Symlink tout d'un coup

```bash
cd ~/dotfiles
stow hypr waybar rofi mako alacritty
```

Stow crée les symlinks. Si `~/.config/hypr` existe déjà en dur (pas un
symlink), stow refuse — supprime/renomme l'ancien dossier avant.

## Retirer un package (désymlink proprement)

```bash
stow -D hypr
```

## Après une modif de config

Rien à faire. Tu édites directement dans `~/.config/hypr/...` (c'est un
symlink vers `~/dotfiles/hypr/.config/hypr/...`), donc `git status` dans
`~/dotfiles` voit direct la modif.

```bash
cd ~/dotfiles
git add -A && git commit -m "hypr: ajout keybind screenshot"
```

## Pourquoi stow et pas un bare repo

Bare repo (`git --bare` + alias `dotfiles`) marche aussi, mais stow est plus
lisible pour toi vu que t'as déjà l'habitude de penser en modules séparés
(comme ton PowerShell). Un package stow = un module = une appli. Cohérent
avec ta façon de bosser.
