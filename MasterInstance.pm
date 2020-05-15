#!/usr/bin/perl -w
use strict;

package MasterInstance;

sub MASTER_INSTANCE_KEY { return 'masterInstance'; }
sub MASTER_CACHE_KEY { return 'masterCache'; }
sub ID_KEY { return 'instanceID'; }

sub newInstance {
    my $self = shift;
    $self = bless({}, ref($self) || $self);
    $self->masterInstance(shift || $self);
    return $self;
}

sub masterInstance { 
    my $self = shift; 
    $self->{$self->MASTER_INSTANCE_KEY} = shift if @_; 
    return $self->{$self->MASTER_INSTANCE_KEY};
}
sub instanceID { 
    my $self = shift;
    if (!exists($self->{$self->ID_KEY}) and @_) {
	my $id = shift;
	$self->{$self->ID_KEY} = $id;
	$self->masterCache($self->ID_KEY, $id, $self);
    }
    return $self->{$self->ID_KEY};

}
sub instanceObject {
    my $self = shift;
    my $object = shift;
    unless (ref $object) {
	my $id = $object;
	my $cache = $self->masterCache($self->ID_KEY, $id);
	return $cache if $cache;
	my $class = $self->classifyObjectID($id);
	$object = $class->newInstance($self->masterInstance);
	$object->instanceID($id);
    }
    return $object;
}
sub classifyObjectID {
    my $self = shift;
    my $id = int(shift || 0);
    return $id % 2 ? 'Odd' : 'Even';
}

sub masterCache {
    my $self = shift;
    my $tag = shift;
    my $id = shift;
    if (@_) {
	$self->masterInstance->{$self->MASTER_CACHE_KEY}{$tag}{$id} = shift;
    }
    return $self->masterInstance->{$self->MASTER_CACHE_KEY}{$tag}{$id};
}
sub masterCacheClear {
    my $self = shift;
    $self->masterInstance->{$self->MASTER_CACHE_KEY} = {};
}

sub DESTROY {
    my $self = shift;
    delete($self->{$self->MASTER_INSTANCE_KEY});
};

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $class = ref($self);
    (my $method = $AUTOLOAD) =~ s/^.*:://;
    my $baseclass = ref($self->masterInstance);
    $self->errorNotImplemented($method, $baseclass, @_) and return unless $class eq $baseclass;
    $self->errorMissingObject($method, $baseclass, @_) and return unless @_; 
    my $object = $self->instanceObject(shift);
    return $object->$method(@_);
} 
sub errorNotImplemented {
    my $self = shift;
    my $method = shift;
    my $baseclass = shift;
    my $class = ref($self);
    warn "$class->$method() not implemented!\n";
}
sub errorMissingObject {
    my $self = shift;
    my $method = shift;
    my $baseclass = shift;
    my $class = ref($self);
    warn "$baseclass->$method() not implemented or missing object!\n";
}

1;
