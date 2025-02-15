package main

import (
	"database/sql"
	"log"
	"os"
	"fmt"
	_ "modernc.org/sqlite"
	"gopkg.in/yaml.v3"
)

const OrgRoamDb = "./org-roam/.org-roam.db"
const OrgRoamRoot = "/home/dcr/org-roam-garden/org-roam"
const BacklinkOutputDir = "/home/dcr/org-roam-garden/data"
const BacklinksFile = "backlinks.yaml"

type Backlink struct {
    File string
    Title string
}

func saveBacklinks(db *sql.DB, file string, file2bl map[string][]Backlink) {
	row, err := db.Query("SELECT file, title FROM nodes WHERE id IN (SELECT DISTINCT l.source AS source FROM nodes n, links l WHERE n.file = ? AND n.id = l.dest)", file)
	if err != nil {
		log.Fatal(err)
	}
	defer row.Close()
	var backlinks []Backlink
	for row.Next() {
		b := Backlink{}
		err := row.Scan(&b.File, &b.Title)
		b.File = b.File[1:(len(b.File)-5)]
		b.Title = b.Title[1:(len(b.Title)-1)]
		if err != nil {
			log.Fatal(err)
		}
		backlinks = append(backlinks, b)
	}
	file = file[1:(len(file)-5)]
	file2bl[file] = backlinks
}

func main() {
	db, err := sql.Open("sqlite", OrgRoamDb)
	if err != nil {
		log.Fatal(err)
	}
	filerow, err := db.Query("SELECT DISTINCT file from nodes")
	if err != nil {
		log.Fatal(err)
	}
	defer filerow.Close()
	file2bl := make(map[string][]Backlink)
	for filerow.Next() {
		var file string
		err := filerow.Scan(&file)
		if err != nil {
			log.Fatal(err)
		}
		saveBacklinks(db, file, file2bl)
	}
	
	blout, err := yaml.Marshal(file2bl)
	if err != nil {
		log.Fatal(err)
	}
	os.MkdirAll(BacklinkOutputDir, 0777)
	f, err := os.Create(fmt.Sprintf("%s/%s", BacklinkOutputDir, BacklinksFile))
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	f.WriteString(string(blout))
}
