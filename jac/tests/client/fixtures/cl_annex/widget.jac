"""Client-placed module whose tests live in an annex. `len` is deliberate: the
client backend has to lower it, so a module compiled outside its own placement
fails here too (#9606)."""

def label(items: list[int]) -> str {
    return f"{len(items)} items";
}
