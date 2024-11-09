SELECT e.id FROM enemy e JOIN material_best_file f ON
    f.type = 'Graphics' AND f.subtype = 'Battlers' AND f.name = e.battler_name