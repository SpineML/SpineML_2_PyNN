<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:EX="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:NL="http://www.shef.ac.uk/SpineMLNetworkLayer" 
xmlns:CL="http://www.shef.ac.uk/SpineMLComponentLayer"
xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>


<xsl:template name="expand_dc_input_array">
<xsl:param name="source_name"/>
<xsl:param name="target"/>
<xsl:param name="target_indices"/>
<xsl:param name="start_time"/>
<xsl:param name="end_time"/>
<xsl:param name="max_index"/>
<xsl:param name="count" select="0"/>
<xsl:choose>
<xsl:when test="$count &lt; $max_index">
<xsl:value-of select="$source_name"/>_<xsl:value-of select="$count"/> = DCSource(amplitude=<xsl:value-of select="$source_name"/>_values[<xsl:value-of select="$count"/>]<xsl:if test="$start_time">, start=<xsl:value-of select="$start_time"/></xsl:if><xsl:if test="$end_time">, stop=<xsl:value-of select="$end_time"/></xsl:if>)
<xsl:value-of select="$source_name"/>_<xsl:value-of select="$count"/>.inject_into(<xsl:value-of select="$target"/><xsl:choose><xsl:when test="$target_indices">[<xsl:value-of select="$target_indices"/>]</xsl:when><xsl:otherwise>[<xsl:value-of select="$count"/>]</xsl:otherwise></xsl:choose>)
<xsl:call-template name="expand_dc_input_array">
	<xsl:with-param name="source_name" select="$source_name"/>
	<xsl:with-param name="target" select="$target"/>
	<xsl:with-param name="target_indices" select="$target_indices"/>
	<xsl:with-param name="start_time" select="$start_time"/>
	<xsl:with-param name="end_time" select="$end_time"/>
	<xsl:with-param name="max_index" select="$max_index"/>
	<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$source_name"/>_<xsl:value-of select="$count"/> = DCSource(amplitude=<xsl:value-of select="$source_name"/>_values[<xsl:value-of select="$count"/>]<xsl:if test="$start_time">, start=<xsl:value-of select="$start_time"/></xsl:if><xsl:if test="$end_time">, stop=<xsl:value-of select="$end_time"/></xsl:if>)
<xsl:value-of select="$source_name"/>_<xsl:value-of select="$count"/>.inject_into(<xsl:value-of select="$target"/> <xsl:choose><xsl:when test="$target_indices">[<xsl:value-of select="$target_indices"/>]</xsl:when><xsl:otherwise>[<xsl:value-of select="$count"/>]</xsl:otherwise></xsl:choose>)
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="set_regular_spike_source_times">
<xsl:param name="source_name"/>
<xsl:param name="start_time"/>
<xsl:param name="end_time"/>
<xsl:param name="rates_array"/>
<xsl:param name="count" select="0"/>
<xsl:choose>
<xsl:when test="contains($rates_array, ',')">
<xsl:variable name="rate" select="substring-before($rates_array,',')"/>
<xsl:variable name="remainingRates" select="substring-after($rates_array,',')"/>
<xsl:value-of select="$source_name"/>[<xsl:value-of select="$count"/>].set('spike_times', numpy.arange(<xsl:value-of select="$start_time"/>, <xsl:value-of select="$end_time"/>, <xsl:value-of select="1.0 div $rate"/>))
<xsl:call-template name="set_regular_spike_source_times">
	<xsl:with-param name="source_name" select="$source_name"/>
	<xsl:with-param name="start_time" select="$start_time"/>
	<xsl:with-param name="end_time" select="$end_time"/>
	<xsl:with-param name="rates_array" select="$remainingRates"/>
	<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$source_name"/>[<xsl:value-of select="$count"/>].set('spike_times', numpy.arange(<xsl:value-of select="$start_time"/>, <xsl:value-of select="$end_time"/>, <xsl:value-of select="1.0 div $rates_array"/>))
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="set_single_spike_source_times">
<xsl:param name="source_name"/>
<xsl:param name="times_array"/>
<xsl:param name="count" select="0"/>
<xsl:choose>
<xsl:when test="contains($times_array, ',')">
<xsl:variable name="time" select="substring-before($times_array,',')"/>
<xsl:variable name="remainingTimes" select="substring-after($times_array,',')"/>
<xsl:value-of select="$source_name"/>[<xsl:value-of select="$count"/>].set('spike_times', [<xsl:value-of select="$time"/>])
<xsl:call-template name="set_single_spike_source_times">
  <xsl:with-param name="source_name" select="$source_name"/>
  <xsl:with-param name="times_array" select="$remainingTimes"/>
  <xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$source_name"/>[<xsl:value-of select="$count"/>].set('spike_times', [<xsl:value-of select="$times_array"/>])
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="check_array_size">
<xsl:param name="name"/>
<xsl:param name="string"/>
<xsl:param name="count" select="1"/>
<xsl:param name="array_size"/>
<xsl:choose>
<xsl:when test="contains($string, ',')">
<xsl:variable name="number" select="substring-before($string,',')"/>
<xsl:variable name="remainingString" select="substring-after($string,',')"/>
<xsl:call-template name="check_array_size">
	<xsl:with-param name="name" select="$name"/>
	<xsl:with-param name="string" select="$remainingString"/>
	<xsl:with-param name="count" select="$count + 1"/>
	<xsl:with-param name="array_size" select="$array_size"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:if test="not($count=$array_size)">
<xsl:message terminate="yes">
ERROR: @array_value string does not match @array_size in <xsl:value-of select="$name"/>
</xsl:message>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="zeros">
<xsl:param name="length"/>
<xsl:choose>
<xsl:when test="$length &gt; 1">0,<xsl:call-template name="zeros">
	<xsl:with-param name="length" select="$length - 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="count_array_items">
<xsl:param name="items"/>
<xsl:param name="count" select="1"/>
<xsl:choose>
<xsl:when test="contains($items, ',')">
<xsl:variable name="item" select="substring-before($items,',')"/>
<xsl:variable name="remaining_items" select="substring-after($items,',')"/>
<xsl:call-template name="count_array_items">
	<xsl:with-param name="items" select="$remaining_items"/>
	<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$count"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="write_target">
<xsl:param name="pop_name"/>
<xsl:param name="pop_name_orig"/>
<xsl:param name="current_experiment"/>
<xsl:variable name="pop_size" select="NL:Neuron/@size"/>
<xsl:variable name="pop_comp_url" select="translate(NL:Neuron/@url, ' ', '_')"/>
<xsl:variable name="pop_comp_name" select="substring($pop_comp_url, 1, string-length($pop_comp_url)-4)"/>

<xsl:for-each select="NL:Projection/NL:Synapse">
<xsl:variable name="dst_pop_name_orig" select="../@dst_population"/>
<xsl:variable name="dst_pop_name" select="translate($dst_pop_name_orig,' ', '_')"/>
<xsl:variable name="proj_name" select="concat('Projection_', $pop_name, '_', $dst_pop_name)"/>
#<xsl:value-of select="$proj_name"/><xsl:text>
</xsl:text>
<xsl:choose><!-- Lesion test by experiment layer -->
<xsl:when test="$current_experiment/EX:Model/EX:Lesion[(@src_population=$pop_name_orig) and (@dst_population=$dst_pop_name_orig)]">#PROJECTION LESIONED IN EXPERIMENT LAYER
</xsl:when><xsl:otherwise>
<!-- Test the target to make sure it is either excitatory or inhibitory -->										
<xsl:variable name="target" select="concat(
										  substring('excitatory', 1, number(NL:PostSynapse/@output_dst_port = 'w_E')  * string-length('excitatory')),
										  substring('inhibitory', 1, number(NL:PostSynapse/@output_dst_port = 'w_I')  * string-length('inhibitory')),
										  substring('unknown',    1, number(not(NL:PostSynapse/@output_dst_port = 'w_E') and not(NL:PostSynapse/@output_dst_port = 'w_I'))  * string-length('unknown'))

										)"/> <!-- Beckers method for creating target type depending on psp dst port value-->
<xsl:if test="$target = 'unknown'">
<xsl:message terminate="yes">
ERROR: Projection '<xsl:value-of select="$proj_name"/>' target type not specified in SpineML 'PostSynapse/@output_dst_port'. Value must be 'w_E' or 'w_I'
</xsl:message>
</xsl:if>

<!-- Connection type -->
<xsl:choose>
<xsl:when test="NL:FixedProbabilityConnection">
<xsl:choose> <!-- Set a seed? -->
<xsl:when test="NL:FixedProbabilityConnection/@seed"><xsl:value-of select="$proj_name"/>_rng = NumpyRNG(seed=<xsl:value-of select="NL:FixedProbabilityConnection/@seed"/>)
</xsl:when>
<xsl:otherwise><xsl:value-of select="$proj_name"/>_rng = NumpyRNG()
</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="$proj_name"/> = Projection(<xsl:value-of select="$pop_name"/>, <xsl:value-of select="$dst_pop_name"/>, FixedProbabilityConnector(<xsl:value-of select="NL:FixedProbabilityConnection/@probability"/>), target='<xsl:value-of select="$target"/>', rng=<xsl:value-of select="$proj_name"/>_rng)
</xsl:when>
<xsl:when test="NL:OneToOneConnection">
<xsl:value-of select="$proj_name"/> = Projection(<xsl:value-of select="$pop_name"/>, <xsl:value-of select="$dst_pop_name"/>, OneToOneConnector(), target='<xsl:value-of select="$target"/>')
</xsl:when>
<xsl:when test="NL:AllToAllConnection">
<xsl:value-of select="$proj_name"/> = Projection(<xsl:value-of select="$pop_name"/>, <xsl:value-of select="$dst_pop_name"/>, AllToAllConnector(allow_self_connections=True), target='<xsl:value-of select="$target"/>')
</xsl:when>
<xsl:when test="NL:ConnectionList"><!-- build a connection list -->
<xsl:value-of select="$proj_name"/>_conn_list = numpy.zeros((<xsl:value-of select="$pop_name"/>_size*<xsl:value-of select="$dst_pop_name"/>_size, 4), dtype=int)
<xsl:value-of select="$proj_name"/>_conn_dict = {<xsl:for-each select="NL:ConnectionList/NL:Connection"><xsl:if test="position()&gt;1">, </xsl:if><xsl:value-of select="position()-1"/>:(<xsl:value-of select="@src_neuron"/>, <xsl:value-of select="@dst_neuron"/>, 0, <xsl:choose><xsl:when test="@delay"><xsl:value-of select="@delay"/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose>)</xsl:for-each>}
<xsl:value-of select="$proj_name"/> = Projection(<xsl:value-of select="$pop_name"/>, <xsl:value-of select="$dst_pop_name"/>, FromListConnector(insert_dict(<xsl:value-of select="$proj_name"/>_conn_dict, <xsl:value-of select="$proj_name"/>_conn_list)), target='<xsl:value-of select="$target"/>')	
</xsl:when>
</xsl:choose>

<!-- Delay values -->
<xsl:choose>
<xsl:when test="*/NL:Delay/NL:FixedValue">
<xsl:value-of select="$proj_name"/>.setDelays(<xsl:value-of select="*/NL:Delay/NL:FixedValue/@value"/>)
</xsl:when>
<xsl:when test="*/NL:Delay/NL:NormalDistribution|*/NL:Delay/NL:UniformDistribution|*/NL:Delay/NL:PoissonDistribution">
<!-- switch on distribution -->
<xsl:choose> <!-- Set a seed? -->
<xsl:when test="*/NL:Delay/*/@seed"><xsl:value-of select="$proj_name"/>_delay_rng = NumpyRNG(seed=<xsl:value-of select="*/NL:Delay/*/@seed"/>)
</xsl:when>
<xsl:otherwise><xsl:value-of select="$proj_name"/>_delay_rng = NumpyRNG()
</xsl:otherwise>
</xsl:choose>
<xsl:choose> <!-- distribution type -->
<xsl:when test="*/NL:Delay/NL:NormalDistribution"><xsl:value-of select="$proj_name"/>.randomizeDelays(RandomDistribution('normal', [<xsl:value-of select="*/NL:Delay/NL:NormalDistribution/@mean"/>, math.sqrt(<xsl:value-of select="*/NL:Delay/NL:NormalDistribution/@variance"/>)], rng=<xsl:value-of select="$proj_name"/>_delay_rng))	#mean, std_dev
</xsl:when>
<xsl:when test="*/NL:Delay/NL:UniformDistribution"><xsl:value-of select="$proj_name"/>.randomizeDelays(RandomDistribution('uniform', [<xsl:value-of select="*/NL:Delay/NL:UniformDistribution/@minimum"/>, <xsl:value-of select="*/NL:Delay/NL:UniformDistribution/@maximum"/>], rng=<xsl:value-of select="$proj_name"/>_delay_rng))	#low, high
</xsl:when>
<xsl:when test="*/NL:Delay/NL:PoissonDistribution"><xsl:value-of select="$proj_name"/>.randomizeDelays(RandomDistribution('poisson', [<xsl:value-of select="*/NL:Delay/NL:PoissonDistribution/@mean"/>], rng=<xsl:value-of select="$proj_name"/>_delay_rng))	#mean 
</xsl:when>
</xsl:choose>
</xsl:when>
</xsl:choose>

<!-- WeightUpdate Weights -->
<xsl:for-each select="NL:WeightUpdate/NL:Property|$current_experiment/EX:Model/EX:Configuration[@target=$proj_name]/NL:Property">
<xsl:variable name="prop_name" select="@name"/>
<!-- Give a warning for any WeightUpdate Property that is not weight! -->
<xsl:if test="not($prop_name='w') and not(number(NL:FixedValue/@value)=0)">warnings.warn("Projection '<xsl:value-of select="$proj_name"/>' Property '<xsl:value-of select="$prop_name"/>' is not supported by the PyNN simulator. It will be ignored!", Warning)
</xsl:if>
<xsl:if test="$prop_name='w'">

<xsl:choose>
<!-- Fixed value weight -->
<xsl:when test="NL:FixedValue"> 
<xsl:value-of select="$proj_name"/>.setWeights(<xsl:value-of select="NL:FixedValue/@value"/>)
</xsl:when>
 <!-- Weight list type -->
<xsl:when test="NL:ValueList/NL:Value">
<xsl:value-of select="$proj_name"/>_g_dict = {<xsl:for-each select="NL:ValueList/NL:Value"><xsl:if test="position()&gt;1">, </xsl:if><xsl:value-of select="@index"/>:<xsl:value-of select="@value"/></xsl:for-each>}
<xsl:value-of select="$proj_name"/>.setWeights(insert_dict(<xsl:value-of select="$proj_name"/>_g_dict, numpy.array(<xsl:value-of select="$proj_name"/>.getWeights())))
</xsl:when>
<!-- Stochastic weight value -->
<xsl:when test="NL:NormalDistribution|NL:UniformDistribution|NL:PoissonDistribution"> 
<xsl:choose> <!-- Set a seed? -->
<xsl:when test="*/@seed"><xsl:value-of select="$proj_name"/>_g_rng = NumpyRNG(seed=<xsl:value-of select="*/@seed"/>)
</xsl:when>
<xsl:otherwise><xsl:value-of select="$proj_name"/>_g_rng = NumpyRNG()
</xsl:otherwise>
</xsl:choose>
<xsl:choose> <!-- distribution type -->
<xsl:when test="NL:NormalDistribution"><xsl:value-of select="$proj_name"/>.randomizeWeights(RandomDistribution('normal', [<xsl:value-of select="NL:NormalDistribution/@mean"/>, math.sqrt(<xsl:value-of select="NL:NormalDistribution/@variance"/>)], rng=<xsl:value-of select="$proj_name"/>_g_rng))	#mean, std_dev
</xsl:when>
<xsl:when test="NL:UniformDistribution"><xsl:value-of select="$proj_name"/>.randomizeWeights(RandomDistribution('uniform', [<xsl:value-of select="NL:UniformDistribution/@minimum"/>, <xsl:value-of select="NL:UniformDistribution/@maximum"/>], rng=<xsl:value-of select="$proj_name"/>_g_rng))	#low, high
</xsl:when>
<xsl:when test="NL:PoissonDistribution"><xsl:value-of select="$proj_name"/>.randomizeWeights(RandomDistribution('poisson', [<xsl:value-of select="NL:PoissonDistribution/@mean"/>], rng=<xsl:value-of select="$proj_name"/>_g_rng))	#mean 
</xsl:when>
</xsl:choose>
</xsl:when>
</xsl:choose> <!-- g value type -->
</xsl:if>
</xsl:for-each> <!-- for each synapse property -->
</xsl:otherwise></xsl:choose> <!-- Lesion test -->
</xsl:for-each> <!-- for each Synapse -->
</xsl:template>


<xsl:template match="/">
#model generated by SpineML to PyNN XSLT Template

import warnings
import numpy
import math
from pyNN.utility import get_script_args
simulator_name = get_script_args(1)[0]  
exec("from pyNN.%s import *" % simulator_name)
from pyNN.random import *
from pyNN.standardmodels import cells

#function to insert dictionary index value pairs into an array
def insert_dict(dict, array):
	for item in dict:
		array[item] = dict[item]
	return array

<!-- Experiments -->
<xsl:for-each select="/EX:SpineML/EX:Experiment">

<xsl:message terminate="no">
Translating SpineML Experiment to PyNN
</xsl:message>

<xsl:variable name="current_experiment" select="."/>
# START EXPERIMENT <xsl:value-of select="@name"/>
<xsl:message terminate="no">WARNING: PyNN does not allow specification of numerical integration schemas. Default simulator scheme will be used!
</xsl:message>
setup(timestep=<xsl:value-of select="EX:Simulation//@dt"/>)

<xsl:variable name="network_layer" select="document(concat('./model/', EX:Model/@network_layer_url))"/> 

<!-- Population sizes -->
#Population sizes
<xsl:for-each select="$network_layer/NL:SpineML/NL:Population">
<xsl:variable name="pop_name" select="translate(NL:Neuron/@name,' ', '_')"/>
<xsl:value-of select="$pop_name"/>_size = <xsl:value-of select="NL:Neuron/@size"/>
<xsl:text>
</xsl:text>
</xsl:for-each>

#############
#Populations#
#############
<!-- Populations (spike sources are not handled as populations but are created as inputs)-->
<xsl:for-each select="$network_layer/NL:SpineML/NL:Population[not(NL:Neuron/@url='PyNNSpikeSource.xml')]">
<xsl:variable name="pop_name_orig" select="NL:Neuron/@name"/>
<xsl:variable name="pop_name" select="translate($pop_name_orig,' ', '_')"/>
<xsl:variable name="pop_size" select="NL:Neuron/@size"/>
<xsl:variable name="pop_comp_url" select="translate(NL:Neuron/@url, ' ', '_')"/>
<xsl:variable name="pop_comp_name" select="substring($pop_comp_url, 1, string-length($pop_comp_url)-4)"/>
<xsl:variable name="neuron_component" select="document(concat('./model/',NL:Neuron/@url))"/>
#<xsl:value-of select="$pop_name"/> Population
<xsl:value-of select="$pop_name"/> = Population(<xsl:value-of select="$pop_size"/>, <xsl:value-of select="$pop_comp_name"/>, label="<xsl:value-of select="$pop_name"/>")
#<xsl:value-of select="$pop_name"/> Population parameters and state variables
<xsl:for-each select="NL:Neuron/NL:Property|$current_experiment/EX:Model/EX:Configuration[@target=$pop_name]/NL:Property">
<xsl:variable name="prop_name" select="@name"/>
<!-- Parameter or State Variable-->
<xsl:choose>
<!-- Parameter -->
<xsl:when test="$neuron_component//CL:Parameter[@name=$prop_name]">
<xsl:choose>
<!-- Fixed value Property type -->
<xsl:when test="NL:FixedValue"> 
<xsl:value-of select="$pop_name"/>.set('<xsl:value-of select="$prop_name"/>', <xsl:value-of select="NL:FixedValue/@value"/>)
</xsl:when>
 <!-- Value list Property type -->
<xsl:when test="NL:ValueList/NL:Value">
<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_dict = {<xsl:for-each select="NL:ValueList/NL:Value"><xsl:if test="position()&gt;1">, </xsl:if><xsl:value-of select="@index"/>:<xsl:value-of select="@value"/></xsl:for-each>}
<xsl:value-of select="$pop_name"/>.tset('<xsl:value-of select="$prop_name"/>', insert_dict(<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_dict, numpy.array(<xsl:value-of select="$pop_name"/>.get('<xsl:value-of select="$prop_name"/>'))))
</xsl:when>
<!-- Stochastic Property value -->
<xsl:when test="NL:UniformDistribution|NL:NormalDistribution|NL:PoissonDistribution"> 
<xsl:choose> <!-- Set a seed? -->
<xsl:when test="*/@seed"><xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng = NumpyRNG(seed=<xsl:value-of select="*/@seed"/>)
</xsl:when>
<xsl:otherwise><xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng = NumpyRNG()
</xsl:otherwise>
</xsl:choose> <!-- end set a seed -->
<xsl:choose> <!-- distribution type -->
<xsl:when test="NL:NormalDistribution"><xsl:value-of select="$pop_name"/>.rset('<xsl:value-of select="$prop_name"/>', RandomDistribution('normal', [<xsl:value-of select="NL:NormalDistribution/@mean"/>, math.sqrt(<xsl:value-of select="NL:NormalDistribution/@variance"/>)], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#mean, std_dev
</xsl:when>
<xsl:when test="NL:UniformDistribution"><xsl:value-of select="$pop_name"/>.rset('<xsl:value-of select="$prop_name"/>', RandomDistribution('uniform', [<xsl:value-of select="NL:UniformDistribution/@minimum"/>, <xsl:value-of select="NL:UniformDistribution/@maximum"/>], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#low, high
</xsl:when>
<xsl:when test="NL:PoissonDistribution"><xsl:value-of select="$pop_name"/>.rset('<xsl:value-of select="$prop_name"/>', RandomDistribution('poisson', [<xsl:value-of select="NL:PoissonDistribution/@mean"/>], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#mean 
</xsl:when> <!-- distribution type -->
</xsl:choose>
</xsl:when>
</xsl:choose> <!-- Property value type -->
</xsl:when>
<!-- State Variable -->
<xsl:when test="$neuron_component//CL:StateVariable[@name=$prop_name]">
<xsl:choose>
<!-- Fixed value Property type -->
<xsl:when test="NL:FixedValue"> <xsl:if test="not(number(NL:FixedValue/@value) = 0)">	<!-- Only set state value fixed values if they are not equal to zero -->
<xsl:value-of select="$pop_name"/>.initialize('<xsl:value-of select="$prop_name"/>', <xsl:value-of select="NL:FixedValue/@value"/>)
</xsl:if></xsl:when>
 <!-- Value list Property type -->
<xsl:when test="NL:ValueList/NL:Value">
warnings.warn("Property lists for State Variables are not supported for State Variable '<xsl:value-of select="$prop_name"/>' in Population '<xsl:value-of select="$pop_name"/>'. List values will be ignored!", Warning)
</xsl:when>
<!-- Stochastic Property value -->
<xsl:when test="NL:UniformDistribution|NL:NormalDistribution|NL:PoissonDistribution"> 
<xsl:choose> <!-- Set a seed? -->
<xsl:when test="*/@seed"><xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng = NumpyRNG(seed=<xsl:value-of select="*/@seed"/>)
</xsl:when>
<xsl:otherwise><xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng = NumpyRNG()
</xsl:otherwise>
</xsl:choose>
<xsl:choose> <!-- distribution type -->
<xsl:when test="NL:NormalDistribution"><xsl:value-of select="$pop_name"/>.initialize('<xsl:value-of select="$prop_name"/>', RandomDistribution('normal', [<xsl:value-of select="NL:NormalDistribution/@mean"/>, math.sqrt(<xsl:value-of select="NL:NormalDistribution/@variance"/>)], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#mean, std_dev
</xsl:when>
<xsl:when test="NL:UniformDistribution"><xsl:value-of select="$pop_name"/>.initialize('<xsl:value-of select="$prop_name"/>', RandomDistribution('uniform', [<xsl:value-of select="NL:UniformDistribution/@minimum"/>, <xsl:value-of select="NL:UniformDistribution/@maximum"/>], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#low, high
</xsl:when>
<xsl:when test="NL:PoissonDistribution"><xsl:value-of select="$pop_name"/>.initialize('<xsl:value-of select="$prop_name"/>', RandomDistribution('poisson', [<xsl:value-of select="NL:PoissonDistribution/@mean"/>], rng=<xsl:value-of select="$pop_name"/>_<xsl:value-of select="$prop_name"/>_rng))	#mean 
</xsl:when>
</xsl:choose>
</xsl:when>
</xsl:choose> <!-- Property value type -->
</xsl:when>
<xsl:otherwise>warnings.warn("Population '<xsl:value-of select="$pop_name"/>' Property '<xsl:value-of select="$prop_name"/>' is neither a parameter or state variable. It will be ignored!", Warning)
</xsl:otherwise>
</xsl:choose> <!-- parameter or state variable -->
</xsl:for-each>	<!-- for each Property -->
<xsl:if test="$current_experiment/EX:LogOutput[@target=$pop_name_orig]">#set recording
<xsl:if test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='spike']">
<xsl:variable name="indices">
<xsl:choose>
<xsl:when test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='spike']/@indices">[[<xsl:value-of select="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='spike']/@indices"/>]]</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$pop_name"/><xsl:value-of select="$indices"/>.record()
</xsl:if>
<xsl:if test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='v']">
<xsl:variable name="indices">
<xsl:choose>
<xsl:when test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='v']/@indices">[[<xsl:value-of select="$current_experiment/EX:LogOutput[@target=$pop_name_orig and @port='v']/@indices"/>]]</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$pop_name"/><xsl:value-of select="$indices"/>.record_v()
</xsl:if>
<xsl:if test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and (@port='I_Syn_E' or @port='I_Syn_I')]">	<!-- Only possible for condunctance based neurons -->
<xsl:variable name="indices">
<xsl:choose>
<xsl:when test="$current_experiment/EX:LogOutput[@target=$pop_name_orig and (@port='I_Syn_E' or @port='I_Syn_I')]/@indices">[[<xsl:value-of select="$current_experiment/EX:LogOutput[@target=$pop_name_orig and (@port='I_Syn_E' or @port='I_Syn_I')]/@indices"/>]]</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$pop_name"/><xsl:value-of select="$indices"/>.record_gsyn()
</xsl:if>
</xsl:if>

</xsl:for-each> <!-- for each Population -->


#############
#  Inputs   #
#############
<!-- ConstantInput -->
<xsl:for-each select="$current_experiment/EX:ConstantInput">
<xsl:variable name="target" select="@target"/>
<xsl:variable name="target_name" select="translate($target,' ', '_')"/>
<xsl:variable name="source_name" select="translate(@name, ' ', '_')"/>
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target])">
<xsl:message terminate="yes">
ERROR: ConstantInput target '<xsl:value-of select="$target"/>' not specified in Network Layer as neuron body name.
</xsl:message>
</xsl:when>
<!-- DC Input-->
<xsl:when test="@port='I_external'">
#DC Current Input
<xsl:value-of select="$source_name"/> = DCSource(amplitude=<xsl:value-of select="@value"/><xsl:if test="@start_time">, start=<xsl:value-of select="@start_time"/></xsl:if><xsl:if test="@duration">, stop=<xsl:value-of select="@start_time+@duration"/></xsl:if>)
<xsl:value-of select="$source_name"/>.inject_into(<xsl:value-of select="$target_name"/><xsl:if test="@target_indices">[<xsl:value-of select="@target_indices"/>]</xsl:if>)
</xsl:when>
<!-- SpikeSource -->
<xsl:when test="@port='spike_in'">
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @url='PyNNSpikeSource.xml'])">
<xsl:message terminate="yes">
ERROR: ConstantInput to port 'spike_in' must use PyNNSpikeSource.xml for the target component!
</xsl:message>
</xsl:when>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @size=1])">
<xsl:message terminate="yes">
ERROR: ConstantInput to port 'spike_in' must have a target population size of 1 (Hint: use ConstantInputArray for >1)!
</xsl:message>
</xsl:when>
<xsl:when test="@target_indices">
<xsl:message terminate="yes">
ERROR: ConstantInput to port 'spike_in' can not set target indices. Connectivity must be configured in the network layer for each projection/synapse!
</xsl:message>
</xsl:when>
<xsl:when test="@rate_based_distribution='poisson'">
#Poisson Spike Input
<xsl:value-of select="$source_name"/> = SpikeSourcePoisson(rate=<xsl:value-of select="@value"/><xsl:if test="@start_time">, start=<xsl:value-of select="@start_time"/></xsl:if><xsl:if test="@duration">, duration=<xsl:value-of select="@duration"/></xsl:if>)
</xsl:when>
<xsl:when test="@rate_based_distribution='regular'">
#Regular Spike Input
<xsl:variable name="start_time">
<xsl:choose>
<xsl:when test="@start_time"><xsl:value-of select="@start_time"/></xsl:when>
<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="end_time">
<xsl:choose>
<xsl:when test="@duration"><xsl:value-of select="@start_time + @duration"/></xsl:when>
<xsl:otherwise><xsl:value-of select="../EX:Simulation/@duration"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$source_name"/> = SpikeSourceArray(spike_times=numpy.arange(<xsl:value-of select="$start_time"/>, <xsl:value-of select="$end_time"/>, <xsl:value-of select="1.0 div @value"/>))
</xsl:when>
<xsl:when test="not(@rate_based_distribution)">
#Single Spike Input
<xsl:value-of select="$source_name"/> = SpikeSourceArray(spike_times=[<xsl:value-of select="@value"/>])
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="yes">
ERROR: ConstantInput '<xsl:value-of select="@name"/>' to port 'spike_in' does not specify a rate_based_distribution (values are 'regular' or 'poisson')!
</xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
warnings.warn("ConstantInput '<xsl:value-of select="@name"/>' port can only be 'I_external' or 'spike_in'. It will be ignored!", Warning)
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>

<!-- ConstantInputArray -->
<xsl:for-each select="$current_experiment/EX:ConstantArrayInput">
<xsl:variable name="target" select="@target"/>
<xsl:variable name="target_name" select="translate($target,' ', '_')"/>
<xsl:variable name="source_name" select="translate(@name, ' ', '_')"/>
<!-- Check array size against array_values -->
<xsl:call-template name="check_array_size">
	<xsl:with-param name="name" select="$source_name"/>
	<xsl:with-param name="string" select="@array_value"/>
	<xsl:with-param name="array_size" select="@array_size"/>
</xsl:call-template>
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target])">
<xsl:message terminate="yes">
ERROR: ConstantInputArray target '<xsl:value-of select="$target"/>' not specified in Network Layer as neuron body name.
</xsl:message>
</xsl:when>
<xsl:when test="@array_size != $network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target]/@size">
<xsl:message terminate="yes">
ERROR: ConstantInputArray '<xsl:value-of select="@name"/>' size does not match target size!
</xsl:message>
</xsl:when>
<!-- DC Current Array (needs to be expanded to multiple PyNN Objects) -->
<xsl:when test="@port='I_external'">
#DC Current Input Array
<xsl:value-of select="$source_name"/>_values = [<xsl:value-of select="@array_value"></xsl:value-of>]
<xsl:call-template name="expand_dc_input_array">
	<xsl:with-param name="source_name" select="$source_name"/>
	<xsl:with-param name="target" select="$target_name"/>
	<xsl:with-param name="target_indices" select="@target_indices"/>
	<xsl:with-param name="start_time" select="@start_time"/>
	<xsl:with-param name="end_time" select="@start_time + @duration"/>
	<xsl:with-param name="max_index" select="@array_size - 1"/>
</xsl:call-template>
</xsl:when>
<!-- Spike Array -->
<xsl:when test="@port='spike_in'">
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @url='PyNNSpikeSource.xml'])">
<xsl:message terminate="yes">
ERROR: ConstantInputArray to port 'spike_in' must use PyNNSpikeSource.xml for the target component!
</xsl:message>
</xsl:when>
<xsl:when test="@target_indices">
<xsl:message terminate="yes">
ERROR: ConstantInputArray to port 'spike_in' can not set target indices. Connectivity must be configured in the network layer for each projection/synapse!
</xsl:message>
</xsl:when>
<xsl:when test="@rate_based_distribution='poisson'">
#Population Poisson Spike Source Array
<xsl:value-of select="$source_name"/> = Population(<xsl:value-of select="@array_size"/>, SpikeSourcePoisson, '<xsl:value-of select="$source_name"/>')
<xsl:if test="@start_time"><xsl:value-of select="$source_name"/>.set('start', <xsl:value-of select="@start_time"/>)</xsl:if>
<xsl:if test="@duration"><xsl:value-of select="$source_name"/>.set('duration', <xsl:value-of select="@duration"/>)</xsl:if>
<xsl:value-of select="$source_name"/>.tset('rate', numpy.array(<xsl:value-of select="@array_value"/>))
</xsl:when>
<xsl:when test="@rate_based_distribution='regular'">
#Population Regular Spike Source Array
<xsl:value-of select="$source_name"/> = Population(<xsl:value-of select="@array_size"/>, SpikeSourceArray, '<xsl:value-of select="$source_name"/>')
<xsl:variable name="start_time">
<xsl:choose>
<xsl:when test="@start_time"><xsl:value-of select="@start_time"/></xsl:when>
<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="end_time">
<xsl:choose>
<xsl:when test="@duration"><xsl:value-of select="@start_time + @duration"/></xsl:when>
<xsl:otherwise><xsl:value-of select="../EX:Simulation/@duration"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
	<xsl:call-template name="set_regular_spike_source_times">
		<xsl:with-param name="source_name" select="$source_name"/>
		<xsl:with-param name="start_time" select="$start_time"/>
		<xsl:with-param name="end_time" select="$end_time"/>
		<xsl:with-param name="rates_array" select="@array_value"/>
	</xsl:call-template>
</xsl:when>
<xsl:when test="not(@rate_based_distribution)">
#Population Regular Spike Source Array (single spike times)
<xsl:value-of select="$source_name"/> = Population(<xsl:value-of select="@array_size"/>, SpikeSourceArray, '<xsl:value-of select="$source_name"/>')
<xsl:variable name="start_time">
<xsl:choose>
<xsl:when test="@start_time"><xsl:value-of select="@start_time"/></xsl:when>
<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="end_time">
<xsl:choose>
<xsl:when test="@duration"><xsl:value-of select="@start_time + @duration"/></xsl:when>
<xsl:otherwise><xsl:value-of select="../EX:Simulation/@duration"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
	<xsl:call-template name="set_single_spike_source_times">
		<xsl:with-param name="source_name" select="$source_name"/>
		<xsl:with-param name="times_array" select="@array_value"/>
	</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="yes">
ERROR: ConstantInput '<xsl:value-of select="@name"/>' to port 'spike_in' does not specify a rate_based_distribution (values are 'regular' or 'poisson')!
</xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="yes">
ERROR: ConstantInputArray '<xsl:value-of select="@name"/>' port can only be 'I_external' or 'spike_in'!
</xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>

<!-- TimeVaryingInput -->
<xsl:for-each select="$current_experiment/EX:TimeVaryingInput">
<xsl:variable name="target" select="@target"/>
<xsl:variable name="target_name" select="translate($target,' ', '_')"/>
<xsl:variable name="source_name" select="translate(@name, ' ', '_')"/>
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target])">
<xsl:message terminate="yes">
ERROR: TimeVaryingInput target '<xsl:value-of select="$target"/>' not specified in Network Layer as neuron body name.
</xsl:message>
</xsl:when>
<!-- Stepped Current Inputs -->
<xsl:when test="@port='I_external'">
#DC Stepped Input Current
<xsl:value-of select="$source_name"/> = StepCurrentSource(times=[<xsl:for-each select="EX:TimePointValue">
		<xsl:value-of select="@time"/><xsl:if test="position() &lt; last()">,</xsl:if>
	</xsl:for-each>], amplitudes=[<xsl:for-each select="EX:TimePointValue">
											<xsl:choose>
												<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
												<xsl:otherwise>0</xsl:otherwise>
											</xsl:choose>
											<xsl:if test="position() &lt; last()">,</xsl:if>
										</xsl:for-each>])
<xsl:value-of select="$source_name"/>.inject_into(<xsl:value-of select="$target_name"/><xsl:if test="@target_indices">[<xsl:value-of select="@target_indices"/>]</xsl:if>)
</xsl:when>
<xsl:when test="@port='spike_in'">
<xsl:choose>
<xsl:when test="@rate_based_distribution">
<xsl:message terminate="yes">
ERROR: TimeVaryingInput '<xsl:value-of select="@name"/>' - PyNN does not support stepped rate spike sources.
</xsl:message>
</xsl:when>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @url='PyNNSpikeSource.xml'])">
<xsl:message terminate="yes">
ERROR: TimeVaryingInput to port 'spike_in' must use PyNNSpikeSource.xml for the target component!
</xsl:message>
</xsl:when>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @size=1])">
<xsl:message terminate="yes">
ERROR: TimeVaryingInput to port 'spike_in' must have a target population size of 1 (Hint: use TimeVaryingInputArray for >1)!
</xsl:message>
</xsl:when>
<xsl:when test="@target_indices">
<xsl:message terminate="yes">
ERROR: TimeVaryingInput to port 'spike_in' can not set target indices. Connectivity must be configured in the network layer for each projection/synapse!
</xsl:message>
</xsl:when>
<xsl:otherwise>
#Spike Array of Explicit Spike Times
<xsl:value-of select="$source_name"/> = SpikeSourceArray(spike_times=numpy.arange(<xsl:for-each select="EX:TimePointValue"><xsl:value-of select="@time"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>))
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
warnings.warn("TimeVaryingInput '<xsl:value-of select="@name"/>' can only be mapped to port 'I_external' or 'spike_in'. It will be ignored!", Warning)
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>


<!-- TimeVaryingArrayInput -->
<xsl:for-each select="$current_experiment/EX:TimeVaryingArrayInput">
<xsl:variable name="target" select="@target"/>
<xsl:variable name="target_name" select="translate($target,' ', '_')"/>
<xsl:variable name="source_name" select="translate(@name, ' ', '_')"/>
<xsl:choose>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target])">
<xsl:message terminate="yes">
ERROR: TimeVaryingArrayInput target '<xsl:value-of select="$target"/>' not specified in Network Layer as neuron body name.
</xsl:message>
</xsl:when>
<xsl:when test="@array_size != $network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target]/@size">
<xsl:message terminate="yes">
ERROR: TimeVaryingArrayInput '<xsl:value-of select="@name"/>' size does not match target size!
</xsl:message>
</xsl:when>
<!-- Stepped Current Input Array  -->
<xsl:when test="@port='I_external'">
#DC Stepped Input Current Array
<xsl:for-each select="EX:TimePointArrayValue">
<xsl:value-of select="$source_name"/>_<xsl:value-of select="@index"/> = StepCurrentSource(times=[<xsl:value-of select="@array_time"/>], amplitudes=[<xsl:choose>
	<xsl:when test="@array_value">
		<xsl:value-of select="@array_value"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="time_points">
			<xsl:call-template name="count_array_items">
				<xsl:with-param name="items" select="@array_time"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="zeros">
			<xsl:with-param name="length" select="$time_points"/>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>])
<xsl:value-of select="$source_name"/>_<xsl:value-of select="@index"/>.inject_into(<xsl:value-of select="$target_name"/><xsl:choose><xsl:when test="@target_indices">[<xsl:value-of select="@target_indices"/>]</xsl:when><xsl:otherwise>[<xsl:value-of select="@index"/>]</xsl:otherwise></xsl:choose>)
</xsl:for-each>
</xsl:when>
<xsl:when test="@port='spike_in'">
<xsl:choose>
<xsl:when test="@rate_based_distribution">
<xsl:message terminate="yes">
ERROR: TimeVaryingInputArray '<xsl:value-of select="@name"/>' - PyNN does not support stepped rate spike sources.
</xsl:message>
</xsl:when>
<xsl:when test="not($network_layer/NL:SpineML/NL:Population/NL:Neuron[@name=$target and @url='PyNNSpikeSource.xml'])">
<xsl:message terminate="yes">
ERROR: TimeVaryingInputArray to port 'spike_in' must use PyNNSpikeSource.xml for the target component!
</xsl:message>
</xsl:when>
<xsl:when test="@target_indices">
<xsl:message terminate="yes">
ERROR: imeVaryingInputArray to port 'spike_in' can not set target indices. Connectivity must be configured in the network layer for each projection/synapse!
</xsl:message>
</xsl:when>
<xsl:otherwise>
#Population of Spike Source Array with Explicit Spike Times
<xsl:value-of select="$source_name"/> = Population(<xsl:value-of select="@array_size"/>, SpikeSourceArray, '<xsl:value-of select="$source_name"/>')
<xsl:for-each select="EX:TimePointArrayValue">
<xsl:value-of select="$source_name"/>[<xsl:value-of select="@index"/>].set('spike_times', numpy.array(<xsl:value-of select="@array_time"/>))
</xsl:for-each>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
warnings.warn("TimeVaryingArrayInputArray '<xsl:value-of select="@name"/>' can only be mapped to port 'I_external' or 'spike_in'. It will be ignored!", Warning)
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>

#############
#Projections#
#############
<!-- Projections (must have pre-declared any populations) -->
<xsl:for-each select="$network_layer/NL:SpineML/NL:Population">
<xsl:variable name="population" select="."/>
<xsl:variable name="pop_name_orig" select="NL:Neuron/@name"/>
<xsl:choose>
<!-- SpikeArrayInputs are a special case and must be mapped to multiple projections -->
<xsl:when test="NL:Neuron/@url='PyNNSpikeSource.xml'">
<xsl:for-each select="$current_experiment/*[@target=$pop_name_orig]">
<xsl:variable name="pop_name" select="translate(@name,' ', '_')"/>
	<xsl:for-each select="$population">
	<xsl:call-template name="write_target">
		<xsl:with-param name="pop_name" select="$pop_name"/>
		<xsl:with-param name="pop_name_orig" select="$pop_name_orig"/>
		<xsl:with-param name="current_experiment" select="$current_experiment"/>
	</xsl:call-template>
	</xsl:for-each>
</xsl:for-each>
</xsl:when>
<!-- Standard Projection -->
<xsl:otherwise>
	<xsl:variable name="pop_name" select="translate($pop_name_orig,' ', '_')"/>
	<xsl:call-template name="write_target">
		<xsl:with-param name="pop_name" select="$pop_name"/>
		<xsl:with-param name="pop_name_orig" select="$pop_name_orig"/>
		<xsl:with-param name="current_experiment" select="$current_experiment"/>
	</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each> <!-- for each Population -->

#run experiment
run(<xsl:value-of select="EX:Simulation/@duration * 1000"/>)

<xsl:for-each select="EX:LogOutput">
<xsl:variable name="target" select="translate(@target,' ', '_')"/>
<xsl:variable name="output_name" select="translate(@name,' ', '_')"/>
<xsl:choose>
<xsl:when test="@port='spike'">
<xsl:value-of select="$target"/>.printSpikes("<xsl:value-of select="$output_name"/>_spikes.dat")
</xsl:when>
<xsl:when test="@port='v'">
<xsl:value-of select="$target"/>.print_v("<xsl:value-of select="$output_name"/>_v.dat")
</xsl:when>
<xsl:when test="@port='I_Syn_E' or @port='I_Syn_I'">
<xsl:value-of select="$target"/>.print_gsyn("<xsl:value-of select="$output_name"/>_gsyn.dat")
</xsl:when>
<xsl:otherwise>
warnings.warn("LogOutput '<xsl:value-of select="@name"/>' can only log ports 'spike', 'v', 'I_Syn_E' or 'I_Syn_I'. Log will be ignored!", Warning)
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>

end()
# END EXPERIMENT <xsl:value-of select="@name"/>
</xsl:for-each> <!-- for each experiment -->
<xsl:message terminate="no">Translation of SpineML to PyNN Successfull

</xsl:message>

</xsl:template>
</xsl:stylesheet>


