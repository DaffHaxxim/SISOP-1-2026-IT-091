BEGIN {
    FS = ","
    option = ARGV[2]
    delete ARGV[2]
}

NR > 1 {
    total++

    carriage[$4] = 1

    age = $2 + 0
    total_age += age

    if (total == 1 || age > max_age) {
        max_age = age
        oldest = $1
    }

    if ($3 == "Business") {
        business_count++
    }
}

END {
    if (option == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " total " orang"
    } else if (option == "b") {
        carriage_count = 0
        for (c in carriage) {
            carriage_count++
        }
        print "Jumlah gerbong penumpang KANJ adalah " carriage_count
    } else if (option == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    } else if (option == "d") {
        if (total > 0) {
            average_age = int(total_age / total)
        } else {
            average_age = 0
        }
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    } else if (option == "e") {
        print "Jumlah penumpang business class ada " business_count+0 " orang"
    } else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        exit 1
    }
}
