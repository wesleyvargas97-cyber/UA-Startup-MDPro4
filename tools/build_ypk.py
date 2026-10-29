#!/usr/bin/env python3
"""Build a minimal MDPro4 custom-card .ypk package."""
from pathlib import Path
import sqlite3, zipfile, shutil
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "dist"
WORK = ROOT / "build" / "ypk"
OUT.mkdir(parents=True, exist_ok=True)
if WORK.exists():
    shutil.rmtree(WORK)
(WORK / "script").mkdir(parents=True)
(WORK / "pics").mkdir()
(WORK / "pack").mkdir()

# Standard YGOPro/ocgcore card database tables.
db = WORK / "custom.cdb"
con = sqlite3.connect(db)
con.executescript("""
CREATE TABLE datas (
 id INTEGER PRIMARY KEY, ot INTEGER, alias INTEGER, setcode INTEGER,
 type INTEGER, atk INTEGER, def INTEGER, level INTEGER, race INTEGER,
 attribute INTEGER, category INTEGER
);
CREATE TABLE texts (
 id INTEGER PRIMARY KEY, name TEXT, desc TEXT,
 str1 TEXT, str2 TEXT, str3 TEXT, str4 TEXT, str5 TEXT, str6 TEXT,
 str7 TEXT, str8 TEXT, str9 TEXT, str10 TEXT, str11 TEXT, str12 TEXT,
 str13 TEXT, str14 TEXT, str15 TEXT, str16 TEXT, desc2 TEXT
);
""")
card_id = 210000001
# TYPE_SPELL=2, TYPE_NORMAL=0x40000. Setcode U.A.=0x7a.
con.execute("INSERT INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (card_id, 0, 0, 0x7a, 2 | 0x40000, 0, 0, 0, 0, 0, 0))
desc = ("Add 1 \"U.A.\" monster from your Deck to your hand. "
        "You can only activate 1 \"U.A. Startup\" per turn. "
        "If your opponent Special Summons a monster(s): You can banish this card "
        "from your GY; Special Summon 1 \"U.A.\" monster from your GY.")
strings = [""] * 16
strings[0] = "Add 1 \"U.A.\" monster from your Deck to your hand."
strings[1] = "If your opponent Special Summons a monster(s): You can banish this card from your GY; Special Summon 1 \"U.A.\" monster from your GY."
con.execute("INSERT INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (card_id, "U.A. Startup", desc, *strings, ""))
con.commit()
con.close()

shutil.copy2(ROOT / "script" / "c210000001.lua", WORK / "script" / "c210000001.lua")
# Some MDPro4 builds look for the fixed database filename test-release.cdb.
shutil.copy2(db, WORK / "test-release.cdb")
shutil.copy2(ROOT / "test-strings.conf", WORK / "test-strings.conf")
# Keep pack metadata/config alongside the card database.
(WORK / "corres_srv.ini").write_text("[Card]\\nid=210000001\\nname=U.A. Startup\\n", encoding="utf-8")
shutil.copy2(ROOT / "pack" / "U.A. Startup Demo.ydk", WORK / "pack" / "U.A. Startup Demo.ydk")

# Original placeholder artwork; visual rendering should still be checked in MDPro4.
im = Image.new("RGB", (421, 614), (15, 28, 50))
d = ImageDraw.Draw(im)
for y in range(614):
    t = y / 614
    d.line((0, y, 421, y), fill=(int(12+15*t), int(30+35*t), int(55+70*t)))
d.rounded_rectangle((18, 18, 403, 596), radius=20, outline=(65, 210, 255), width=5)
d.text((32, 42), "U.A. STARTUP", fill=(255, 255, 255))
d.text((32, 275), "U.A.", fill=(80, 220, 255))
d.text((32, 315), "STARTUP", fill=(255, 255, 255))
d.text((32, 565), "CUSTOM CARD • TEST ART", fill=(210, 230, 245))
im.save(WORK / "pics" / "210000001.png")
# JPEG fallback for clients/builds that resolve card art by .jpg.
im.convert("RGB").save(WORK / "pics" / "210000001.jpg", quality=95)

target = OUT / "UA_Startup.ypk"
with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as z:
    for p in sorted(WORK.rglob("*")):
        if p.is_file():
            z.write(p, p.relative_to(WORK).as_posix())
print(f"Built {target} ({target.stat().st_size} bytes)")
