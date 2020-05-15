# MasterInstance
ID number to classed object framework

## Synopsis

    package MasterInstance;
    my $master = MasterInstance->newInstance;
    my $object = instanceObject($id);
    print "$id is ".ref($object)."\n";

Due to the default classifyObjectID, the above example will print "Odd\n" for odd $id and "Even\n" for even $id.

## Typical usage
This package is typically subclassed for a database frontend. The classifyObjectID() is overloaded to return correct class for a given ID.

    package HomeDB;
    use parent qw(MasterInstance);
    sub classifyObjectID { 
      my $self = shift;
      my $id = shift;
      if ($id =~ /\d/) { return "Residens"; }
      else             { return "Person"; }
    }
  
    package Residence;
    sub area { return 125; } # Calculate are of the residence
    sub show {
     my $self = shift;
      printf("Address: %s\nArea: %d m2\n", $self->instanceID, $self->area);
    }
  
    package Person;
    sub age { return int((time() - shift->birth) / (365.25 * 86400)); }
    sub show { ... }
  
    package MAIN;
    my $db = HomeDB->newInstance;
    my $person = $db->instanceObject("Holmes, Sherlock")
    $person->show;
    $db->show("221B Baker Street"); # short for $db->instanceObject("221B Baker Street")->show;
  
  
  
