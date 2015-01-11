package models;

import js.npm.mongoose.macro.Manager;
import js.npm.mongoose.macro.Model;

typedef VacationInSeasonListenerSchema = {
    email : String,
    skus: Array<String>
}

class VacationInSeasonListenerManager extends Manager<VacationInSeasonListenerSchema, VacationInSeasonListener>
{}

class VacationInSeasonListener extends Model<VacationInSeasonListenerSchema>
{
    public static function build(mongoose) { return VacationInSeasonListenerManager.build(mongoose, "VacationInSeasonListener"); }
}