import sys
import json

# Read input files
pg_file = sys.argv[1]
rs_file = sys.argv[2]

def parse_file(path):
    data = {}
    with open(path) as f:
        for line in f:
            parts = line.strip().split("|") if "|" in line else line.strip().split()
            if len(parts) >= 2:
                name = parts[0].strip()
                count = int(parts[-1])
                data[name] = count
    return data

pg = parse_file(pg_file)
rs = parse_file(rs_file)

print("SOURCE (POSTGRES):", pg)
print("TARGET (REDSHIFT):", rs)

mismatches = []

for table in pg:
    if table not in rs:
        mismatches.append(f"{table} missing in Redshift")
    elif pg[table] != rs[table]:
        mismatches.append(f"{table}: PG={pg[table]} RS={rs[table]}")

if mismatches:
    print("\n DATA MISMATCH FOUND:")
    for m in mismatches:
        print(m)
    sys.exit(1)

print("\n ALL TABLE COUNTS MATCH")