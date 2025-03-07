package main

import (
	"database/sql"
	"log"
	"os"
	"fmt"
	"strings"
	_ "modernc.org/sqlite"
	"gopkg.in/yaml.v3"
)

const OrgRoamDb = "./org-roam/.org-roam.db"
const OrgRoamRoot = "org-roam/"
const BacklinkOutputDir = "assets/data"
const BacklinksFile = "backlinks.yaml"

type Backlink struct {
    File string
    Title string
}

func stripQuotes(str string) string {
	return str[1:(len(str)-1)]
}

// strips quotes plus the .org at the end, the trims the abs root
func cleanFile(root string, str string) string {
	return strings.TrimLeft(str[1:(len(str)-5)], fmt.Sprintf("%s/%s", root, OrgRoamRoot))
}

func saveBacklinks(db *sql.DB, root string, file string, file2bl map[string][]Backlink) {
	row, err := db.Query("SELECT file, title FROM nodes WHERE id IN (SELECT DISTINCT l.source AS source FROM nodes n, links l WHERE n.file = ? AND n.id = l.dest)", file)
	if err != nil {
		log.Fatal(err)
	}
	defer row.Close()
	var backlinks []Backlink
	for row.Next() {
		b := Backlink{}
		err := row.Scan(&b.File, &b.Title)
		if err != nil {
			log.Fatal(err)
		}
		b.File = cleanFile(root, b.File)
		b.Title = stripQuotes(b.Title)
		backlinks = append(backlinks, b)
	}
	file = cleanFile(root, file)
	file2bl[file] = backlinks
}

func main() {
	root := os.Args[1]
	
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
		saveBacklinks(db, root, file, file2bl)
	}
	
	blout, err := yaml.Marshal(file2bl)
	if err != nil {
		log.Fatal(err)
	}
	os.MkdirAll(fmt.Sprintf("%s/%s", root, BacklinkOutputDir), 0777)
	f, err := os.Create(fmt.Sprintf("%s/%s", BacklinkOutputDir, BacklinksFile))
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	f.WriteString(string(blout))
}
