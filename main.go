package main

import (
	"compress/bzip2"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"sort"
	"strings"

	version "github.com/knqyf263/go-rpm-version"
	"golang.org/x/sys/unix"
)

type errataBase struct {
	Name   xml.Name `xml:"opt"`
	Errata []Errata `xml:",any"`
}

// Errata is an individual CEFS errata
type Errata struct {
	XMLName  xml.Name
	OS       int      `xml:"os_release"`
	Packages []string `xml:"packages"`
	Severity string   `xml:"severity,attr"`
}

func main() {
	data := FetchErrata()

	// filter out all interesting security errata for our OS version
	osVer := OSVersion()
	errata := make(map[string]Errata)
	for _, val := range data {
		if val.OS != osVer {
			// don't care about any notifications not for our OS release
			continue
		}
		if strings.HasPrefix(val.XMLName.Local, "CESA") {
			errata[val.XMLName.Local] = val
		}
	}

	// grab system packages and find advisories that update installed packages
	pkgs := SystemPackages()
	needsUpdate := make(map[string]string)
	for _, entry := range errata {
		errataPackages := EntryPackages(entry)
		for errataName, errataVer := range errataPackages {
			sysVer, exists := pkgs[errataName]
			if !exists {
				// package is not installed, we can ignore it
				continue
			}

			// is it newer than the system package AND newer than the last version
			// we marked as needing an update?
			if CmpVer(sysVer, errataVer) {
				lastUpdateVer, exists := needsUpdate[errataName]
				if exists && !CmpVer(lastUpdateVer, errataVer) {
					continue
				}
				needsUpdate[errataName] = errataVer
			}
		}
	}

	// now dump packages with security updates to stdout
	var sorted []string
	for pkg, version := range needsUpdate {
		sorted = append(sorted, pkg+"-"+TrimRelease(version))
	}
	sort.Strings(sorted)
	for _, pkg := range sorted {
		fmt.Println(pkg)
	}
}

// OSVersion gets the EL release major version (eg. CentOS 6)
func OSVersion() int {
	buf := unix.Utsname{}
	unix.Uname(&buf)
	if strings.Contains(string(buf.Release[:]), "el6") {
		return 6
	}
	return 7
}

// FetchErrata gets the latest errata from CEFS
func FetchErrata() []Errata {
	bz2, err := http.Get("https://cefs.steve-meier.de/errata.latest.xml.bz2")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer bz2.Body.Close()
	reader := bzip2.NewReader(bz2.Body)
	rawXML, _ := ioutil.ReadAll(reader)
	parsed := errataBase{}
	xml.Unmarshal(rawXML, &parsed)
	return parsed.Errata
}

// ParsePackage splits a package name into its name + version
func ParsePackage(pkg string) (string, string) {
	s := strings.Split(pkg, "-")
	// strip everything following the release (".el7.x86_64")
	version := s[len(s)-2] + "-" + strings.Split(s[len(s)-1], ".")[0]
	name := strings.Join(s[:len(s)-2], "-")
	return name, version
}

// SystemPackages fetches a list of all system packages via "rpm -qa"
func SystemPackages() map[string]string {
	stdout, _ := exec.Command("rpm", "-qa").Output()
	pkgs := strings.Split(string(stdout), "\n")

	sysPkgs := make(map[string]string)
	for i := 0; i < len(pkgs)-1; i++ {
		name, version := ParsePackage(pkgs[i])
		sysPkgs[name] = version
	}
	return sysPkgs
}

// EntryPackages converts a CEFS errata entry to a list of unique package
// versions. Ignores duplicate entries for different architectures/
// SRPMs/etc.
func EntryPackages(entry Errata) map[string]string {
	pkgs := make(map[string]string)
	for _, pkg := range entry.Packages {
		if strings.Contains(pkg, "centos.alt") {
			// skip alternate kernels provided by Xen4Centos
			continue
		}
		name, version := ParsePackage(pkg)
		pkgs[name] = version
	}
	return pkgs
}

// CmpVer returns true if ver2's version is newer than ver1
func CmpVer(ver1 string, ver2 string) bool {
	v1 := version.NewVersion(ver1)
	v2 := version.NewVersion(ver2)
	return v2.GreaterThan(v1)
}

// TrimRelease strips the release from the version number
func TrimRelease(version string) string {
	s := strings.Split(version, "-")
	return strings.Join(s[:len(s)-1], "-")
}
